// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import Foundation
import MinimalAuthExample

struct RegisterController {
    let userStore: UserStore
    let emailValidator: EmailValidator
    let passwordValidator: PasswordValidator
    let tokenProvider: AuthTokenProvider
    let passwordHasher: PasswordHasher
    
    public struct UserAlreadyExists: Error {}
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    
    func register(email: String, password: String) async throws -> String {
        guard try userStore.findUser(byEmail: email) == nil else {
            throw UserAlreadyExists()
        }
        
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(password) else {
            throw InvalidPasswordError()
        }
        
        let hashedPassword = try await passwordHasher(password)
        let userID = UUID()
        try userStore.createUser(id: userID, email: email, hashedPassword: hashedPassword)
        return try await tokenProvider(userID, email)
    }
}
