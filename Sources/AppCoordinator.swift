// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public typealias EmailValidator  = (_ email: String) -> Bool
public typealias PasswordValidator = (_ password: String) -> Bool
public typealias AuthTokenProvider = (_ userId: UUID, _ email: String) async throws -> String
public typealias AuthTokenVerifier = (_ token: String) async throws -> UUID
public typealias PasswordHasher = (_ input: String) async throws -> String
public typealias PasswordVerifier = (_ password: String, _ hash: String) async throws -> Bool

public class AppCoordinator: @unchecked Sendable {
    
    private let registerController: RegisterController
    private let loginController: LoginController
    private let recipesController: RecipesController
    
    public init(userStore: UserStore, recipeStore: RecipeStore, emailValidator: @escaping EmailValidator, passwordValidator: @escaping PasswordValidator, tokenProvider: @escaping AuthTokenProvider, tokenVerifier: @escaping AuthTokenVerifier, passwordHasher: @escaping PasswordHasher, passwordVerifier: @escaping PasswordVerifier) {
        registerController = RegisterController(userStore: userStore, emailValidator: emailValidator, passwordValidator: passwordValidator, tokenProvider: tokenProvider, passwordHasher: passwordHasher)
        loginController = LoginController(userStore: userStore, emailValidator: emailValidator, passwordValidator: passwordValidator, tokenProvider: tokenProvider, passwordVerifier: passwordVerifier)
        recipesController = RecipesController(store: recipeStore, tokenVerifier: tokenVerifier)
    }
    
    public struct UserAlreadyExists: Error {}
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    public struct NotFoundUserError: Error {}
    public struct IncorrectPasswordError: Error {}
    
    public func register(email: String, password: String) async throws -> [String: String] {
        let token = try await registerController.register(email: email, password: password)
        return ["token": token]
    }
    
    public func login(email: String, password: String) async throws -> [String: String] {
        let token = try await loginController.login(email: email, password: password)
        return ["token": token]
    }
    
    public func getRecipes(accessToken: String) async throws -> [Recipe] {
        try await recipesController.getRecipes(accessToken: accessToken)
    }
    
    public func createRecipe(accessToken: String, title: String) async throws -> Recipe {
        try await recipesController.postRecipe(accessToken: accessToken, title: title)
    }
}
