// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public class CodableUserStore: UserStore {
    private let storeURL: URL
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func get() throws -> [User] {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
        let data = try Data(contentsOf: storeURL)
        return try JSONDecoder().decode([CodableStoredUser].self, from: data).map(UserMapper.map)
    }
    
    public func saveUser(_ user: User) throws {
        var users = try get()
        users.append(user)
        let data = try JSONEncoder().encode(users.map(UserMapper.map))
        try data.write(to: storeURL)
    }
    
    public func findUser(byEmail email: String) throws -> User? {
       return try get().first { $0.email == email }
    }
}


private struct CodableStoredUser: Codable {
    let id: UUID
    let email: String
}

private enum UserMapper {
    static func map(_ user: CodableStoredUser) -> User {
        User(id: user.id, email: user.email)
    }
    
    static func map(_ user: User) -> CodableStoredUser {
        CodableStoredUser(id: user.id, email: user.email)
    }
}
