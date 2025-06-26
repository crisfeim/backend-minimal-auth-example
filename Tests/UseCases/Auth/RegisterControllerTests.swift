// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import XCTest
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

class RegisterControllerTests: XCTestCase {
    
    func test_init_doesntMessagesStoreUponCreation() throws {
        let store = UserStoreSpy()
        let _ = makeSUT(store: store)
        XCTAssertEqual(store.messages, [])
    }
    
    func test_register_deliversErrorOnStoreSaveError() async throws {
        let store = UserStoreStub(
            findUserResult: .success(anyUser()),
            saveResult: .failure(anyError())
        )
        let sut = makeSUT(store: store)
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password"))
    }
    
    func test_register_deliversErrorOnAlreadyExistingUser() async throws {
        let store = UserStoreStub(
            findUserResult: .success(anyUser()),
            saveResult: .success(())
        )
        let sut = makeSUT(store: store)
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is RegisterController.UserAlreadyExists)
        }
    }
    
    func test_register_deliversErrorOnInvalidEmail() async throws {
        let store = UserStoreStub(
            findUserResult: .success(nil),
            saveResult: .success(())
        )
        let sut = makeSUT(store: store, emailValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
            
            XCTAssertTrue(error is RegisterController.InvalidEmailError)
        }
    }
    
    func test_register_deliversErrorOnInvalidPassword() async throws {
        let store = UserStoreStub(
            findUserResult: .success(nil),
            saveResult: .success(())
        )
        let sut = makeSUT(store: store, passwordValidator: { _ in false })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is RegisterController.InvalidPasswordError)
        }
    }
    
    func test_register_deliversProvidedTokenOnNewUserValidCredentialsAndUserStoreSuccess() async throws {
        let store = UserStoreStub(
            findUserResult: .success(nil),
            saveResult: .success(())
        )
        
        let sut = makeSUT(store: store, tokenProvider: { _,_ in "any-provided-token" })
        let token = try await sut.register(email: "any-email", password: "any-password")
        XCTAssertEqual(token, "any-provided-token")
    }
    
    func test_register_deliversErrorOnHasherError() async throws {
        let store = UserStoreStub(
            findUserResult: .success(nil),
            saveResult: .success(())
        )
        let sut = makeSUT(store: store, hasher: { _ in throw self.anyError() })
        await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password"))
    }
    
    
    func makeSUT(
        store: UserStore,
        emailValidator: @escaping EmailValidator = { _ in true },
        passwordValidator: @escaping PasswordValidator = { _ in true },
        tokenProvider: @escaping AuthTokenProvider = { _,_ in "any" },
        hasher: @escaping PasswordHasher = { $0 }
    ) -> RegisterController {
        return RegisterController(
            userStore: store,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider,
            passwordHasher: hasher,
        )
    }
}
