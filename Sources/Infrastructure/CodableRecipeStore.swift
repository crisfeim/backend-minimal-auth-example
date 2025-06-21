// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public class CodableRecipeStore {
    private let store: CodableStore<CodableRecipe>
    
    public init(storeURL: URL) {
        self.store = .init(storeURL: storeURL)
    }
    
    public func getRecipes() throws -> [Recipe] {
        try store.get().map(RecipeMapper.map)
    }
    
    public func createRecipe(userId: UUID, title: String) throws -> Recipe {
        let recipe = CodableRecipe(id: UUID(), userId: userId, title: title)
        try store.save(recipe)
        return RecipeMapper.map(recipe)
    }
}

private struct CodableRecipe: Codable {
    let id: UUID
    let userId: UUID
    let title: String
}

private enum RecipeMapper {
    static func map(_ recipe: Recipe) -> CodableRecipe {
        CodableRecipe(
            id: recipe.id,
            userId: recipe.userId,
            title: recipe.title
        )
    }
    
    static func map(_ recipe: CodableRecipe) -> Recipe {
        Recipe(
            id: recipe.id,
            userId: recipe.userId,
            title: recipe.title
        )
    }
}
