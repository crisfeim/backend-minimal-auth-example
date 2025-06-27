// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


import Foundation

public protocol RecipeStore {
    func getRecipes() throws -> [Recipe]
    func createRecipe(userId: UUID, title: String) throws -> Recipe
}