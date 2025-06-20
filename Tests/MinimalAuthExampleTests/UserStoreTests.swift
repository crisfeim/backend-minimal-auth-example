// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest

class UserStoreTests: XCTestCase {
    
    struct User: Equatable {
        let id: UUID
    }
    
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
    
    override func setUp() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    func test_get_deliversNoUsersOnEmptyStore() throws {
        let sut = CodableUserStore(storeURL: testSpecificURL())
        let users = try sut.get()
        XCTAssertEqual(users, [])
    }
    
    func test_saveUser_savesUser() throws {
        let sut = CodableUserStore(storeURL: testSpecificURL())
        let user = User(id: UUID())
        try sut.saveUser(user)
        let users = try sut.get()
        XCTAssertEqual(users, [user])
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).json")
    }
}
