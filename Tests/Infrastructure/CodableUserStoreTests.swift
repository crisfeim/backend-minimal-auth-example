// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class CodableUserStoreTests: XCTestCase {
    override func setUp() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    func test_getUsers_deliversNoUsersOnEmptyStore() throws {
        let sut = CodableUserStore(storeURL: testSpecificURL())
        let users = try sut.getUsers()
        XCTAssertEqual(users, [])
    }
    
    func test_saveUser_savesUser() throws {
        let sut = CodableUserStore(storeURL: testSpecificURL())
        let user = anyUser()
        try sut.saveUser(id: user.id, email: user.email, hashedPassword: user.hashedPassword)
        let users = try sut.getUsers()
        XCTAssertEqual(users, [user])
    }
    
    func test_findUserByEmail_returnsUserIfExists() throws {
        let sut = CodableUserStore(storeURL: testSpecificURL())
        let user = User(id: UUID(), email: "hi@crisfe.im", hashedPassword: "hashedPassword")
        try sut.saveUser(id: user.id, email: user.email, hashedPassword: user.hashedPassword)
        let foundUser = try sut.findUser(byEmail: "hi@crisfe.im")
        XCTAssertEqual(foundUser, user)
    }
    
    private func anyUser() -> User {
        User(id: UUID(), email: "any@email.com", hashedPassword: "any hashed password")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).json")
    }
}
