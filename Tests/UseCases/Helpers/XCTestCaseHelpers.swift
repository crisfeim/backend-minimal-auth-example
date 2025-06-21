// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

extension XCTestCase {
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func anyRecipe() -> Recipe {
        Recipe(id: UUID(), userId: UUID(), title: "any-title")
    }
    
    func anyUser() -> User {
        User(id: UUID(), email: "any-user@email.com", hashedPassword: "any-hashed-password")
    }
}
