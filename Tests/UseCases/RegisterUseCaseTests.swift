// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class RegisterUseCaseTests: XCTestCase {
    func test_init_doesntMessagesStoreUponCreation() throws {
        let store = UserStoreSpy()
        let _ = makeSUT(store: store)
        XCTAssertEqual(store.messages, [])
    }
    
    func test_register_deliversErrorOnStoreSaveError() throws {
        let store = UserStoreStub(
            findUserResult: .success(anyUser()),
            saveResult: .failure(anyError())
        )
        let sut = makeSUT(store: store)
        XCTAssertThrowsError(try sut.register(email: "any-email", password: "any-password"))
    }
    
    func test_register_deliversErrorOnAlreadyExistingUser() throws {
        let store = UserStoreStub(
            findUserResult: .success(anyUser()),
            saveResult: .success(())
        )
        let sut = makeSUT(store: store)
        XCTAssertThrowsError(try sut.register(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is RecipesApp.UserAlreadyExists)
        }
    }
    
    func test_register_deliversErrorOnInvalidEmail() throws {
        let store = UserStoreStub(
            findUserResult: .success(nil),
            saveResult: .success(())
        )
        let sut = makeSUT(store: store, emailValidator: { _ in false })
        XCTAssertThrowsError(try sut.register(email: "any-email", password: "any-password")) { error in
            
            XCTAssertTrue(error is RecipesApp.InvalidEmailError)
        }
    }
    
    func test_register_deliversErrorOnInvalidPassword() throws {
        let store = UserStoreStub(
            findUserResult: .success(nil),
            saveResult: .success(())
        )
        let sut = makeSUT(store: store, passwordValidator: { _ in false })
        XCTAssertThrowsError(try sut.register(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is RecipesApp.InvalidPasswordError)
        }
    }
    
    func test_register_deliversProvidedTokenOnNewUserValidCredentialsAndUserStoreSuccess() throws {
        let store = UserStoreStub(
            findUserResult: .success(nil),
            saveResult: .success(())
        )
        
        let sut = makeSUT(store: store, tokenProvider: { _ in "any-provided-token" })
        let token = try sut.register(email: "any-email", password: "any-password")
        XCTAssertEqual(token["token"], "any-provided-token")
    }
    
    func makeSUT(
        store: UserStore,
        emailValidator: @escaping EmailValidator = { _ in true },
        passwordValidator: @escaping PasswordValidator = { _ in true },
        tokenProvider: @escaping AuthTokenProvider = { _ in "any-token" }
    ) -> RecipesApp {
        return RecipesApp(
            userStore: store,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider
        )
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func anyUser() -> User {
        User(id: UUID(), email: "any-user@email.com", hashedPassword: "any-hashed-password")
    }
}


// MARK: - Double
private extension RegisterUseCaseTests {
    class UserStoreSpy: UserStore {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case findUser(byEmail: String)
            case saveUser(User)
        }
        
        func saveUser(_ user: User) throws {
            messages.append(.saveUser(user))
        }
        
        func findUser(byEmail email: String) throws -> User? {
            messages.append(.findUser(byEmail: email))
            return nil
        }
    }
    
    struct UserStoreStub: UserStore {
        let findUserResult: Result<User?, Error>
        let saveResult: Result<Void, Error>
        func findUser(byEmail email: String) throws -> User? {
            try findUserResult.get()
        }
        
        func saveUser(_ user: User) throws {
            try saveResult.get()
        }
    }
}
