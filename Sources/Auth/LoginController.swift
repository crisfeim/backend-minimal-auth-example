// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

public struct LoginController<UserId> {
    
    public typealias UserFinder = (_ email: String) throws -> User?
    public struct User {
        fileprivate let id: UserId
        fileprivate let hashedPassword: String
        
        public init(id: UserId, hashedPassword: String) {
            self.id = id
            self.hashedPassword = hashedPassword
        }
    }
    
    private let userFinder: UserFinder
    private let emailValidator: EmailValidator
    private let passwordValidator: PasswordValidator
    private let tokenProvider: AuthTokenProvider<UserId>
    private let passwordVerifier: PasswordVerifier
    
    public init(
        userFinder: @escaping UserFinder,
        emailValidator: @escaping EmailValidator,
        passwordValidator: @escaping PasswordValidator,
        tokenProvider: @escaping AuthTokenProvider<UserId>,
        passwordVerifier: @escaping PasswordVerifier
    ) {
        self.userFinder = userFinder
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.tokenProvider = tokenProvider
        self.passwordVerifier = passwordVerifier
    }
    
    public func login(email: String, password: String) async throws -> String {
        guard emailValidator(email) else {
            throw InvalidEmailError()
        }
        
        guard passwordValidator(email) else {
            throw InvalidPasswordError()
        }
        
        guard let user = try userFinder(email) else {
            throw NotFoundUserError()
        }
        
        guard try await passwordVerifier(password, user.hashedPassword) else {
            throw IncorrectPasswordError()
        }
        
        return try await tokenProvider(user.id, email)
    }
}
