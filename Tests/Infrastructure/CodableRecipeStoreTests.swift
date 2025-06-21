// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class CodableRecipeStoreTests: XCTestCase {
    
    
    
    override func setUp() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    func test_getRecipes_deliversNoRecipesOnEmptyStore() throws {
        let sut = CodableRecipeStore(storeURL: testSpecificURL())
        let recipes = try sut.getRecipes()
        XCTAssertEqual(recipes, [])
    }
    
    func test_createRecipe_createsRecipe() throws {
        let sut = CodableRecipeStore(storeURL: testSpecificURL())
        let recipe = try sut.createRecipe(userId: anyUUID(), title: "any recipe title")
        XCTAssertTrue(try sut.getRecipes().contains(recipe))
    }
    
    private func anyUUID() -> UUID { UUID() }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self))")
    }
}
