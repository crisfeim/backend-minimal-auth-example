// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

public struct LoginController {
    private let userStore: UserStore
    private let emailValidator: EmailValidator
    private let passwordValidator: PasswordValidator
    private let tokenProvider: AuthTokenProvider
    private let passwordVerifier: PasswordVerifier
    
    public init(
        userStore: UserStore,
        emailValidator: @escaping EmailValidator,
        passwordValidator: @escaping PasswordValidator,
        tokenProvider: @escaping AuthTokenProvider,
        passwordVerifier: @escaping PasswordVerifier
    ) {
        self.userStore = userStore
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
        self.passwordVerifier = passwordVerifier
    }
    
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    public struct NotFoundUserError: Error {}
    public struct IncorrectPasswordError: Error {}
    
    public func login(email: String, password: String) async throws -> String {
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
        
        return try await tokenProvider(user.id, email)
    }
}
