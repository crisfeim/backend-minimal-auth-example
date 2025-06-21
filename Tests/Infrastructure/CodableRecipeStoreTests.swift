// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class CodableRecipeStoreTests: XCTestCase {
    
    class CodableRecipeStore {
        let storeURL: URL
        
        init(storeURL: URL) {
            self.storeURL = storeURL
        }
        
        struct CodableRecipe: Codable {
            let id: UUID
            let userId: UUID
            let title: String
        }
        
        func getRecipes() throws -> [Recipe] {
            try get().map {
                Recipe(id: $0.id, userId: $0.userId, title: $0.title)
            }
        }
        
        private func get() throws -> [CodableRecipe] {
            guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
            let data = try Data(contentsOf: storeURL)
            return try JSONDecoder().decode([CodableRecipe].self, from: data)
        }
        
        func createRecipe(userId: UUID, title: String) throws -> Recipe {
            let recipe = CodableRecipe(id: UUID(), userId: userId, title: title)
            var recipes = try get()
            recipes.append(recipe)
            let data = try JSONEncoder().encode(recipes)
            try data.write(to: storeURL)
            return Recipe(id: recipe.id, userId: recipe.userId, title: recipe.title)
        }
    }
    
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
