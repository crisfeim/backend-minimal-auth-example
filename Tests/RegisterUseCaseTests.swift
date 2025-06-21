// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class RegisterUseCaseTests: XCTestCase {
    
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
        let saveResult: Result<Void, Error>
        func findUser(byEmail email: String) throws -> User? {
            return nil
        }
        
        func saveUser(_ user: User) throws {
            try saveResult.get()
        }
    }
    
    class RecipesApp {
        let store: UserStore
        
        init(store: UserStore) {
            self.store = store
        }
        
        func register(email: String, password: String) throws {
            try store.saveUser(User(id: UUID(), email: email, hashedPassword: password))
        }
    }
    
    func test_init_doesntMessagesStoreUponCreation() throws {
        let store = UserStoreSpy()
        let _ = RecipesApp(store: store)
        XCTAssertEqual(store.messages, [])
    }
    
    func test_register_deliversErrorOnStoreError() throws {
        let store = UserStoreStub(saveResult: .failure(anyError()))
        let sut = RecipesApp(store: store)
        XCTAssertThrowsError(try sut.register(email: "any-email", password: "any-password"))
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
