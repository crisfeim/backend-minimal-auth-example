// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class GetRecipesUseCaseTests: XCTestCase {
   
    func test_getRecipes_deliversErrorOnStoreError() async throws {
        let store = RecipeStoreStub(result: .failure(anyError()))
        let sut = makeSUT(store: store)
        await XCTAssertThrowsErrorAsync(try await sut.getRecipes(accessToken: "any valid access token"))
    }
    
    func test_getRecipes_deliversErrorOnTokenVerifierError() async throws {
        let store = RecipeStoreStub(result: .success([]))
        let sut = makeSUT(store: store, tokenVerifier: { _ in throw self.anyError() })
        await XCTAssertThrowsErrorAsync(try await sut.getRecipes(accessToken: "any invalid access token"))
    }
    
    func test_getRecipes_deliversErrorOnInvalidAccessToken() async throws {
        let store = RecipeStoreStub(result: .success([]))
        let sut = makeSUT(store: store, tokenVerifier: { _ in throw self.anyError() })
        await XCTAssertThrowsErrorAsync(try await sut.getRecipes(accessToken: "any invalid access token"))
    }
    
    func test_getRecipes_deliversUserRecipesOnCorrectAccessToken() async throws {
        let user = User(id: UUID(), email: "any@email.com", hashedPassword: "1234")
        let otherUserRecipes = [anyRecipe(), anyRecipe(), anyRecipe()]
        let userRecipes = [Recipe(id: UUID(), userId: user.id)]
        let store = RecipeStoreStub(result: .success(otherUserRecipes + userRecipes))
        let sut = makeSUT(store: store, tokenVerifier: { _ in user.id })
        let recipes = try await sut.getRecipes(accessToken: "anyvalidtoken")
        XCTAssertEqual(userRecipes, recipes)
    }
    
    func makeSUT(
        store: RecipeStore,
        tokenVerifier: @escaping AuthTokenVerifier = { _ in UUID() },
    ) -> RecipesApp {
        return RecipesApp(
            userStore: DummyUserStore(),
            recipeStore: store,
            emailValidator: { _ in true },
            passwordValidator: { _ in true },
            tokenProvider: { $0 },
            tokenVerifier: tokenVerifier,
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
    
    func anyRecipe() -> Recipe {
        Recipe(id: UUID(), userId: UUID())
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
