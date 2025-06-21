// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public typealias EmailValidator  = (_ email: String) -> Bool
public typealias PasswordValidator = (_ password: String) -> Bool
public typealias AuthTokenProvider = (_ email: String) -> String

public class RecipesApp {
    private let store: UserStore
    private let emailValidator: EmailValidator
    private let passwordValidator: PasswordValidator
    private let tokenProvider: AuthTokenProvider
    
    public init(store: UserStore, emailValidator: @escaping EmailValidator, passwordValidator: @escaping PasswordValidator, tokenProvider: @escaping AuthTokenProvider) {
        self.store = store
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
    }
    
    public struct UserAlreadyExists: Error {}
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    public struct NotFoundUserError: Error {}
    
    public func register(email: String, password: String) throws -> [String: String] {
        guard try store.findUser(byEmail: email) == nil else {
            throw UserAlreadyExists()
        }
        
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(password) else {
            throw InvalidPasswordError()
        }
        
        try store.saveUser(User(id: UUID(), email: email, hashedPassword: password))
        return ["token": tokenProvider(email)]
    }
    
    public func login(email: String, password: String) throws -> [String: String] {
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(email) else {
            throw InvalidPasswordError()
        }
        
        guard let _ = try store.findUser(byEmail: email) else {
            throw NotFoundUserError()
        }
        
        return ["token": tokenProvider(email)]
    }
}
