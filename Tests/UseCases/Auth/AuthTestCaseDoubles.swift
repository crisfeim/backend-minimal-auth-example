// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


import XCTest
import MinimalAuthExample

class UserStoreSpy: UserStore {
    private(set) var messages = [Message]()
    
    enum Message: Equatable {
        case findUser(byEmail: String)
        case saveUser(id: UUID, email: String, hashedPassword: String)
    }
    
    func createUser(id: UUID, email: String, hashedPassword: String) throws {
        messages.append(.saveUser(id: id, email: email, hashedPassword: hashedPassword))
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
    
    func createUser(id: UUID, email: String, hashedPassword: String) throws {
        try saveResult.get()
    }
}
