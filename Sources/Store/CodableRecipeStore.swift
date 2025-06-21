// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public class CodableRecipeStore {
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct CodableRecipe: Codable {
        let id: UUID
        let userId: UUID
        let title: String
    }
    
    public func getRecipes() throws -> [Recipe] {
        try get().map {
            Recipe(id: $0.id, userId: $0.userId, title: $0.title)
        }
    }
    
    public func createRecipe(userId: UUID, title: String) throws -> Recipe {
        let recipe = CodableRecipe(id: UUID(), userId: userId, title: title)
        var recipes = try get()
        recipes.append(recipe)
        let data = try JSONEncoder().encode(recipes)
        try data.write(to: storeURL)
        return Recipe(id: recipe.id, userId: recipe.userId, title: recipe.title)
    }
    
    private func get() throws -> [CodableRecipe] {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
        let data = try Data(contentsOf: storeURL)
        return try JSONDecoder().decode([CodableRecipe].self, from: data)
    }
}

