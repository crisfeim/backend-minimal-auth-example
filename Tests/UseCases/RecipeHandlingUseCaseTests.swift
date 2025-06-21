// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class RecipeHandlingUseCaseTests: XCTestCase {
   
    func test_getRecipes_deliversErrorOnStoreError() throws {
        let store = RecipeStoreStub(result: .failure(anyError()))
        let sut = makeSUT(store: store)
        XCTAssertThrowsError(try sut.getRecipes())
    }
    
    func makeSUT(
        store: RecipeStore
    ) -> RecipesApp {
        return RecipesApp(
            userStore: DummyUserStore(),
            recipeStore: store,
            emailValidator: { _ in true },
            passwordValidator: { _ in true },
            tokenProvider: { $0 },
            hasher: { $0 },
            passwordVerifier: { _,_ in true }
        )
    }
    
    struct RecipeStoreStub: RecipeStore {
        let result: Result<[Recipe], Error>
        
        func getRecipes() throws -> [Recipe] {
            try result.get()
        }
    }
    
    struct DummyUserStore: UserStore {
        func findUser(byEmail email: String) throws -> User? {
            return nil
        }
        func saveUser(_ user: User) throws {}
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
