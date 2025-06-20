// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest

class UserStoreTests: XCTestCase {
    
    struct User: Equatable {}
    class CodableUserStore {
        func get() -> [User] {[]}
    }
    
    func test_get_deliversNoUsersOnEmptyStore() {
        let sut = CodableUserStore()
        let users = sut.get()
        XCTAssertEqual(users, [])
    }
}
