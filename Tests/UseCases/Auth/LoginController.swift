// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import MinimalAuthExample

struct LoginController {
        let userStore: UserStore
        let emailValidator: EmailValidator
        let passwordValidator: PasswordValidator
        let tokenProvider: AuthTokenProvider
        let passwordVerifier: PasswordVerifier
        
        public struct InvalidEmailError: Error {}
        public struct InvalidPasswordError: Error {}
        public struct NotFoundUserError: Error {}
        public struct IncorrectPasswordError: Error {}
        
        func login(email: String, password: String) async throws -> String {
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
