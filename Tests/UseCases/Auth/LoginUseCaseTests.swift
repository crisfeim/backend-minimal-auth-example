// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class LoginUseCaseTests: XCTestCase {
   
    func test_init_doesntMessagesStoreUponCreation() throws {
        let store = UserStoreSpy()
        let _ = makeSUT(store: store)
        XCTAssertEqual(store.messages, [])
    }
    
    func test_login_deliversErrorOnStoreError() async throws {
        let store = UserStoreStub(findUserResult: .failure(anyError()), saveResult: .success(()))
        let sut = makeSUT(store: store)
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password"))
    }
    
    func test_login_deliversErrorOnNotFoundUser() async throws {
        let store = UserStoreStub(findUserResult: .success(nil), saveResult: .success(()))
        let sut = makeSUT(store: store)
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is LoginController.NotFoundUserError)
        }
    }
    
    func test_login_deliversErrorOnInvalidEmail() async throws {
        let store = UserStoreStub(findUserResult: .success(anyUser()), saveResult: .success(()))
        let sut = makeSUT(store: store, emailValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is LoginController.InvalidEmailError)
        }
    }
    
    func test_login_deliversErrorOnInvalidPassword() async throws {
        let store = UserStoreStub(findUserResult: .success(anyUser()), saveResult: .success(()))
        let sut = makeSUT(store: store, passwordValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is LoginController.InvalidPasswordError)
        }
    }
    
    func test_login_deliversErrorOnPasswordVerifierError() async throws {
        let store = UserStoreStub(findUserResult: .success(anyUser()), saveResult: .success(()))
        let sut = makeSUT(store: store, passwordVerifier: { _, _ in throw self.anyError() })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password"))
    }
    
    func test_login_deliversErrorOnIncorrectPassword() async throws {
        let store = UserStoreStub(findUserResult: .success(anyUser()), saveResult: .success(()))
        let sut = makeSUT(store: store, passwordVerifier: { _, _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is LoginController.IncorrectPasswordError)
        }
    }
    
    func test_login_deliversProvidedTokenOnCorrectCredentialsAndFoundUser() async throws {
        let store = UserStoreStub(findUserResult: .success(anyUser()), saveResult: .success(()))
        let sut = makeSUT(store: store, tokenProvider: { _,_ in "any-provided-token" })
        let token = try await sut.login(email: "any-email", password: "any-password")
        XCTAssertEqual(token["token"], "any-provided-token")
    }
    
    func makeSUT(
        store: UserStore,
        emailValidator: @escaping EmailValidator = { _ in true },
        passwordValidator: @escaping PasswordValidator = { _ in true },
        tokenProvider: @escaping AuthTokenProvider = { _,_ in "any-token" },
        passwordVerifier: @escaping PasswordVerifier = { _,_ in true }
    ) -> AppCoordinator {
        return AppCoordinator(
            userStore: store,
            recipeStore: RecipeStoreDummy(),
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider,
            tokenVerifier: { _ in UUID() },
            passwordHasher: { $0 },
            passwordVerifier: passwordVerifier
        )
    }
}


