// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public class CodableUserStore: UserStore {
    private let storeURL: URL
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func getUsers() throws -> [User] {
        try get().map(UserMapper.map)
    }
    
    public func createUser(id: UUID, email: String, hashedPassword: String) throws {
        let user = CodableUser(id: id, email: email, hashedPassword: hashedPassword)
        var users = try get()
        users.append(user)
        let data = try JSONEncoder().encode(users)
        try data.write(to: storeURL)
    }
    
    public func findUser(byEmail email: String) throws -> User? {
        return try get().first { $0.email == email }.map(UserMapper.map)
    }
    
    private func get() throws -> [CodableUser] {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
        let data = try Data(contentsOf: storeURL)
        return try JSONDecoder().decode([CodableUser].self, from: data)
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
