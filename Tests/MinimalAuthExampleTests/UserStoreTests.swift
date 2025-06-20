// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest

class UserStoreTests: XCTestCase {
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
