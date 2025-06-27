// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import XCTest
import GenericAuth

class LoginControllerTests: XCTestCase {
    
    func test_login_deliversErrorOnUserFinder() async throws {
        let sut = makeSUT(userFinder: { _ in throw self.anyError() })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password"))
    }
    
    func test_login_deliversErrorOnNotFoundUser() async throws {
        let sut = makeSUT(userFinder: { _ in return nil })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is NotFoundUserError)
        }
    }
    
    func test_login_deliversErrorOnInvalidEmail() async throws {
        let sut = makeSUT(userFinder: { _ in self.anyUser() }, emailValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is InvalidEmailError)
        }
    }
    
    func test_login_deliversErrorOnInvalidPassword() async throws {
        let sut = makeSUT(userFinder: { _ in self.anyUser() }, passwordValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is InvalidPasswordError)
        }
    }
    
    func test_login_deliversErrorOnPasswordVerifierError() async throws {
        let sut = makeSUT(userFinder: { _ in self.anyUser() }, passwordVerifier: { _, _ in throw self.anyError() })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password"))
    }
    
    func test_login_deliversErrorOnIncorrectPassword() async throws {
        let sut = makeSUT(userFinder: { _ in self.anyUser() }, passwordVerifier: { _, _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is IncorrectPasswordError)
        }
    }
    
    func test_login_deliversProvidedTokenOnCorrectCredentialsAndFoundUser() async throws {
        let sut = makeSUT(userFinder: { _ in self.anyUser() }, tokenProvider: { _,_ in "any-provided-token" })
        let token = try await sut.login(email: "any-email", password: "any-password")
        XCTAssertEqual(token, "any-provided-token")
    }
    
    func test_login_passwordIsValidatedWithPasswordValidator() async throws {
        var password: String?
        let sut = makeSUT(passwordValidator: {
            password = $0
            return true
        })
        
        _ = try? await sut.login(email: "any email", password: "any password")
        XCTAssertEqual(password, "any password")
    }
    
    func test_login_emailIsValidatedWithEmailValidator() async throws {
        var email: String?
        let sut = makeSUT(emailValidator: {
            email = $0
            return true
        })
        
        _ = try? await sut.login(email: "any email", password: "any password")
        XCTAssertEqual(email, "any email")
    }
    
    func makeSUT(
        userFinder: @escaping LoginController<UUID>.UserFinder = { _ in nil },
        emailValidator: @escaping EmailValidator = { _ in true },
        passwordValidator: @escaping PasswordValidator = { _ in true },
        tokenProvider: @escaping AuthTokenProvider<UUID> = { _,_ in "any-token" },
        passwordVerifier: @escaping PasswordVerifier = { _,_ in true }
    ) -> LoginController<UUID> {
        return LoginController<UUID>(
            userFinder: userFinder,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider,
            passwordVerifier: passwordVerifier
        )
    }
    
    
    func anyUser() -> LoginController<UUID>.User {
        .init(id: UUID(), hashedPassword: "any hashed password")
    }
}
