// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public class CodableUserStore {
    let storeURL: URL
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct CodableStoredUser: Codable {
        let id: UUID
        let email: String
    }
    
    public func get() throws -> [User] {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
        let data = try Data(contentsOf: storeURL)
        return try JSONDecoder().decode([CodableStoredUser].self, from: data).map {
            User(id: $0.id, email: $0.email)
        }
    }
    
    public func saveUser(_ user: User) throws {
        var users = try get()
        users.append(user)
        let mapped = users.map {
            CodableStoredUser(id: $0.id, email: $0.email)
        }
        
        let data = try JSONEncoder().encode(mapped)
        try data.write(to: storeURL)
    }
    
    public func findUser(byEmail email: String) throws -> User? {
       return try get().first { $0.email == email }
    }
}
