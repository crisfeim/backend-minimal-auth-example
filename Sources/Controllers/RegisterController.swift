// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import Foundation

public struct RegisterController {
    private let userStore: UserStore
    private let emailValidator: EmailValidator
    private let passwordValidator: PasswordValidator
    private let tokenProvider: AuthTokenProvider
    private let passwordHasher: PasswordHasher
    
    public init(
        userStore: UserStore,
        emailValidator: @escaping EmailValidator,
        passwordValidator: @escaping PasswordValidator,
        tokenProvider: @escaping AuthTokenProvider,
        passwordHasher: @escaping PasswordHasher
    ) {
        self.userStore = userStore
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
        self.passwordHasher = passwordHasher
    }
    
    public struct UserAlreadyExists: Error {}
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    
    public func register(email: String, password: String) async throws -> String {
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
