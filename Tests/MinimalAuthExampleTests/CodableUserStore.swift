// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

class CodableUserStore {
        let storeURL: URL
        init(storeURL: URL) {
            self.storeURL = storeURL
        }
        
        func get() throws -> [User] {
            guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
            let data = try Data(contentsOf: storeURL)
            return try JSONDecoder().decode([CodableStoredUser].self, from: data).map {
                User(id: $0.id)
            }
        }
        
        private struct CodableStoredUser: Codable {
            let id: UUID
        }
        
        func saveUser(_ user: User) throws {
            var users = try get()
            users.append(user)
            let mapped = users.map {
                CodableStoredUser(id: $0.id)
            }
            
            let data = try JSONEncoder().encode(mapped)
            try data.write(to: storeURL)
        }
    }
