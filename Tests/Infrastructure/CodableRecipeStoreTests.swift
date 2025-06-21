// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class CodableRecipeStoreTests: XCTestCase {
    
    class CodableRecipeStore {
        let storeURL: URL
        
        init(storeURL: URL) {
            self.storeURL = storeURL
        }
        
        func getRecipes() throws -> [Recipe] {
            []
        }
    }
    
    func test_getRecipes_deliversNoRecipesOnEmptyStore() throws {
        let sut = CodableRecipeStore(storeURL: testSpecificURL())
        let recipes = try sut.getRecipes()
        XCTAssertEqual(recipes, [])
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self))")
    }
}
