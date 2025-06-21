// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

final class CodableStore<T: Codable> {
    let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func save(_ object: T) throws {
        var objects = try get()
        objects.append(object)
        let data = try JSONEncoder().encode(objects)
        try data.write(to: storeURL)
    }
    
    func get() throws -> [T] {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
        let data = try Data(contentsOf: storeURL)
        return try JSONDecoder().decode([T].self, from: data)
    }
}


public class CodableUserStore: UserStore {
    private let store: CodableStore<CodableUser>
    public init(storeURL: URL) {
        self.store = .init(storeURL: storeURL)
    }
    
    public func getUsers() throws -> [User] {
        try store.get().map(UserMapper.map)
    }
    
    public func createUser(id: UUID, email: String, hashedPassword: String) throws {
        try store.save(CodableUser(id: id, email: email, hashedPassword: hashedPassword))
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
