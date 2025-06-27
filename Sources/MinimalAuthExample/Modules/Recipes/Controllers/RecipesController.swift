// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import Foundation
import GenericAuth

public struct RecipesController {
    private let store: RecipeStore
    private let tokenVerifier: AuthTokenVerifier
    
    struct UnauthorizedError: Error {}
    private let jsonDecoder = JSONDecoder()
    
    public init(store: RecipeStore, tokenVerifier: @escaping AuthTokenVerifier) {
        self.store = store
        self.tokenVerifier = tokenVerifier
    }
    
    public func postRecipe(accessToken: String, title: String) async throws -> Recipe {
        let userId = try await tokenVerifier(accessToken)
        return try store.createRecipe(userId: userId, title: title)
    }
    
    public func getRecipes(accessToken: String) async throws -> [Recipe] {
        let userId = try await tokenVerifier(accessToken)
        let recipes = try store.getRecipes()

        return recipes.filter { $0.userId == userId }
    }
}
