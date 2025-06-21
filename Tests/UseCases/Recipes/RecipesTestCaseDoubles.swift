// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import MinimalAuthExample

class RecipeStoreSpy: RecipeStore {
    let result: Result<Recipe, Error>
    struct CreateRecipeCommand: Equatable {
        let userId: UUID
        let title: String
    }
    
    var capturedMessages = [CreateRecipeCommand]()
    
    init(result: Result<Recipe, Error>) {
        self.result = result
    }
    
    func getRecipes() throws -> [Recipe] {
        fatalError("should never be called within test case context")
    }
    
    func createRecipe(userId: UUID, title: String) throws -> Recipe {
        capturedMessages.append(.init(userId: userId, title: title))
        return try result.get()
    }
}

struct DummyUserStore: UserStore {
    func findUser(byEmail email: String) throws -> User? {nil}
    func createUser(id: UUID, email: String, hashedPassword: String) throws {}
}
