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
        try sut.createUser(email: user.email, hashedPassword: user.hashedPassword)
        let users = try sut.getUsers()
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.email, user.email)
        XCTAssertEqual(users.first?.hashedPassword, user.hashedPassword)
    }
    
    func test_findUserByEmail_returnsUserIfExists() throws {
        let sut = CodableUserStore(storeURL: testSpecificURL())
        try sut.createUser(email: "hi@crisfe.im", hashedPassword: "any password")
        let foundUser = try sut.findUser(byEmail: "hi@crisfe.im")
        XCTAssertEqual(foundUser?.email, "hi@crisfe.im")
        XCTAssertEqual(foundUser?.hashedPassword, "any password")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).json")
    }
}
