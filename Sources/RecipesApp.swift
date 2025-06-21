// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public typealias EmailValidator  = (_ email: String) -> Bool
public typealias PasswordValidator = (_ password: String) -> Bool
public typealias AuthTokenProvider = (_ email: String) -> String
public typealias AuthTokenVerifier = (_ token: String) async throws -> UUID
public typealias Hasher = (_ input: String) async throws -> String
public typealias PasswordVerifier = (_ password: String, _ hash: String) async throws -> Bool

public protocol RecipeStore {
    func getRecipes() throws -> [Recipe]
}

public class RecipesApp {
    private let userStore: UserStore
    private let recipeStore: RecipeStore
    private let emailValidator: EmailValidator
    private let passwordValidator: PasswordValidator
    private let tokenProvider: AuthTokenProvider
    private let tokenVerifier: AuthTokenVerifier
    private let hasher: Hasher
    private let passwordVerifier: PasswordVerifier
    
    public init(userStore: UserStore, recipeStore: RecipeStore, emailValidator: @escaping EmailValidator, passwordValidator: @escaping PasswordValidator, tokenProvider: @escaping AuthTokenProvider, tokenVerifier: @escaping AuthTokenVerifier, hasher: @escaping Hasher, passwordVerifier: @escaping PasswordVerifier) {
        self.userStore = userStore
        self.recipeStore = recipeStore
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
        self.tokenVerifier = tokenVerifier
        self.hasher = hasher
        self.passwordVerifier = passwordVerifier
    }
    
    public struct UserAlreadyExists: Error {}
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    public struct NotFoundUserError: Error {}
    public struct IncorrectPasswordError: Error {}
    
    public func register(email: String, password: String) async throws -> [String: String] {
        guard try userStore.findUser(byEmail: email) == nil else {
            throw UserAlreadyExists()
        }
        
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(password) else {
            throw InvalidPasswordError()
        }
        
        let hashedPassword = try await hasher(password)
        try userStore.saveUser(User(id: UUID(), email: email, hashedPassword: hashedPassword))
        return ["token": tokenProvider(email)]
    }
    
    public func login(email: String, password: String) async throws -> [String: String] {
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(email) else {
            throw InvalidPasswordError()
        }
        
        guard let user = try userStore.findUser(byEmail: email) else {
            throw NotFoundUserError()
        }
        
        guard try await passwordVerifier(password, user.hashedPassword) else {
            throw IncorrectPasswordError()
        }
        
        return ["token": tokenProvider(email)]
    }
    
    public func getRecipes(accessToken: String) async throws -> [Recipe] {
        let userId = try await tokenVerifier(accessToken)
        let recipes = try recipeStore.getRecipes()

        return recipes.filter { $0.userId == userId }
    }
}
