// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import XCTest
import MinimalAuthExample

class RegisterControllerTests: XCTestCase {

    func test_register_deliversErrorOnStoreSaveError() async throws {
        let sut = makeSUT(userMaker: { _,_ in throw self.anyError() }, userExists: { _ in true })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password"))
    }
    
    func test_register_deliversErrorOnAlreadyExistingUser() async throws {
        let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in true })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is RegisterController<UUID>.UserAlreadyExists)
        }
    }
    
    func test_register_deliversErrorOnInvalidEmail() async throws {
        let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in false }, emailValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
            
            XCTAssertTrue(error is RegisterController<UUID>.InvalidEmailError)
        }
    }
    
    func test_register_deliversErrorOnInvalidPassword() async throws {
        let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in false }, passwordValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is RegisterController<UUID>.InvalidPasswordError)
        }
    }
    
    func test_register_deliversProvidedTokenOnNewUserValidCredentialsAndUserStoreSuccess() async throws {
        let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in false }, tokenProvider: { _,_ in "any-provided-token" })
        let token = try await sut.register(email: "any-email", password: "any-password")
        XCTAssertEqual(token, "any-provided-token")
    }
    
    func test_register_deliversErrorOnHasherError() async throws {
        let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in true }, hasher: { _ in throw self.anyError() })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password"))
    }
    
    
    func makeSUT(
        userMaker: @escaping UserMaker<UUID>,
        userExists: @escaping UserExists,
        emailValidator: @escaping EmailValidator = { _ in true },
        passwordValidator: @escaping PasswordValidator = { _ in true },
        tokenProvider: @escaping AuthTokenProvider<UUID> = { _,_ in "any" },
        hasher: @escaping PasswordHasher = { $0 }
    ) -> RegisterController<UUID> {
        return RegisterController<UUID>(
            userMaker: userMaker,
            userExists: userExists,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider,
            passwordHasher: hasher,
        )
    }
}
