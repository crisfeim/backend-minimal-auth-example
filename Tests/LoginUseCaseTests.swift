// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class LoginUseCaseTests: XCTestCase {
   
    func test_init_doesntMessagesStoreUponCreation() throws {
        let store = UserStoreSpy()
        let _ = makeSUT(store: store)
        XCTAssertEqual(store.messages, [])
    }
    
    func test_login_deliversErrorOnStoreError() throws {
        let store = UserStoreStub(findUserResult: .failure(anyError()), saveResult: .success(()))
        let sut = makeSUT(store: store)
        XCTAssertThrowsError(try sut.login(email: "any-email", password: "any-password"))
    }
    
    func test_login_deliversErrorOnNotFoundUser() throws {
        let store = UserStoreStub(findUserResult: .success(nil), saveResult: .success(()))
        let sut = makeSUT(store: store)
        XCTAssertThrowsError(try sut.login(email: "any-email", password: "any-password")) { error in
            XCTAssertTrue(error is RecipesApp.NotFoundUserError)
        }
    }
    
    func makeSUT(
        store: UserStore,
        emailValidator: @escaping EmailValidator = { _ in true },
        passwordValidator: @escaping PasswordValidator = { _ in true },
        tokenProvider: @escaping AuthTokenProvider = { _ in "any-token" }
    ) -> RecipesApp {
        return RecipesApp(
            store: store,
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider
        )
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

private extension LoginUseCaseTests {
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
