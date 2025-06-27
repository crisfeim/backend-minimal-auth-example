// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation




public class CodableUserStore: UserStore {
    private let store: CodableStore<CodableUser>
    public init(storeURL: URL) {
        self.store = .init(storeURL: storeURL)
    }
    
    public func getUsers() throws -> [User] {
        try store.get().map(UserMapper.map)
    }
    
    @discardableResult
    public func createUser(email: String, hashedPassword: String) throws -> UUID {
        let id = UUID()
        try store.save(CodableUser(id: id, email: email, hashedPassword: hashedPassword))
        return id
    }
    
    public func findUser(byEmail email: String) throws -> User? {
        return try store.get().first { $0.email == email }.map(UserMapper.map)
    }
}


private struct CodableUser: Codable {
    let id: UUID
    let email: String
    let hashedPassword: String
}

private enum UserMapper {
    static func map(_ user: CodableUser) -> User {
        User(id: user.id, email: user.email, hashedPassword: user.hashedPassword)
    }
    
    static func map(_ user: User) -> CodableUser {
        CodableUser(id: user.id, email: user.email, hashedPassword: user.hashedPassword)
    }
}
