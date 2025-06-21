// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import MinimalAuthExample

typealias EmailValidator  = (_ email: String) -> Bool
typealias PasswordValidator = (_ password: String) -> Bool
typealias AuthTokenProvider = (_ email: String) -> String

class RecipesApp {
    let store: UserStore
    let emailValidator: EmailValidator
    let passwordValidator: PasswordValidator
    let tokenProvider: AuthTokenProvider
    
    init(store: UserStore, emailValidator: @escaping EmailValidator, passwordValidator: @escaping PasswordValidator, tokenProvider: @escaping AuthTokenProvider) {
        self.store = store
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
    }
    
    struct UserAlreadyExists: Error {}
    struct InvalidEmailError: Error {}
    struct InvalidPasswordError: Error {}
    struct NotFoundUserError: Error {}
    
    func register(email: String, password: String) throws -> [String: String] {
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
        let token = tokenProvider(email)
        return ["token": token]
    }
    
    func login(email: String, password: String) throws {
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(email) else {
            throw InvalidPasswordError()
        }
        
        guard let _ = try store.findUser(byEmail: email) else {
            throw NotFoundUserError()
        }
    }
}
