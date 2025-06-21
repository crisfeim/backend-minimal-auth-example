// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public typealias EmailValidator  = (_ email: String) -> Bool
public typealias PasswordValidator = (_ password: String) -> Bool
public typealias AuthTokenProvider = (_ email: String) -> String
public typealias Hasher = (_ input: String) async throws -> String

public class RecipesApp {
    private let userStore: UserStore
    private let emailValidator: EmailValidator
    private let passwordValidator: PasswordValidator
    private let tokenProvider: AuthTokenProvider
    private let hasher: Hasher
    
    public init(userStore: UserStore, emailValidator: @escaping EmailValidator, passwordValidator: @escaping PasswordValidator, tokenProvider: @escaping AuthTokenProvider, hasher: @escaping Hasher) {
        self.userStore = userStore
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
        self.hasher = hasher
    }
    
    public struct UserAlreadyExists: Error {}
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    public struct NotFoundUserError: Error {}
    
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
    
    public func login(email: String, password: String) throws -> [String: String] {
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(email) else {
            throw InvalidPasswordError()
        }
        
        guard let _ = try userStore.findUser(byEmail: email) else {
            throw NotFoundUserError()
        }
        
        return ["token": tokenProvider(email)]
    }
}
