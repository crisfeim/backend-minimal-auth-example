// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import Foundation

public typealias UserMaker<UserId> = (_ email: String, _ hashedPassword: String) throws -> UserId
public typealias UserExists = (_ email: String) throws -> Bool

public struct RegisterController<UserId> {
    private let userMaker: UserMaker<UserId>
    private let userExists: UserExists
    private let emailValidator: EmailValidator
    private let passwordValidator: PasswordValidator
    private let tokenProvider: AuthTokenProvider<UserId>
    private let passwordHasher: PasswordHasher
    
    public init(
        userMaker: @escaping UserMaker<UserId>,
        userExists: @escaping UserExists,
        emailValidator: @escaping EmailValidator,
        passwordValidator: @escaping PasswordValidator,
        tokenProvider: @escaping AuthTokenProvider<UserId>,
        passwordHasher: @escaping PasswordHasher
    ) {
        self.userMaker = userMaker
        self.userExists = userExists
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
        self.passwordHasher = passwordHasher
    }
    
    public func register(email: String, password: String) async throws -> String {
        guard try !userExists(email) else {
            throw UserAlreadyExists()
        }
        
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(password) else {
            throw InvalidPasswordError()
        }
        
        let hashedPassword = try await passwordHasher(password)
        let userID = try userMaker(email, hashedPassword)
        return try await tokenProvider(userID, email)
    }
}
