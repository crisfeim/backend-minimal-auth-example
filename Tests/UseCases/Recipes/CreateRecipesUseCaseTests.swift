// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import XCTest
import MinimalAuthExample

class CreateRecipesUseCaseTests: XCTestCase {
    func test_postRecipe_deliversErrorOnStoreError() async throws {
        let store = RecipeStoreStub(result: .failure(anyError()))
        let sut = makeSUT(store: store)
        await XCTAssertThrowsErrorAsync(try await sut.createRecipe(accessToken: "any valid access token", title: "Fried chicken"))
    }
    
    func test_postRecipe_deliversErrorOnInvalidAccessToken() async throws {
        let store = RecipeStoreStub(result: .success(anyRecipe()))
        let sut = makeSUT(store: store, tokenVerifier: { _ in throw self.anyError() })
        
        await XCTAssertThrowsErrorAsync(try await sut.createRecipe(accessToken: "any valid access token", title: "Fried chicken"))
    }
    
    
    func test_postRecipe_deliversRecipeOnSuccess() async throws {
        let stubbedRecipe = anyRecipe()
        let store = RecipeStoreStub(result: .success(stubbedRecipe))
        let sut = makeSUT(store: store)
        
        let recipe = try await sut.createRecipe(accessToken: "any valid access token", title: "Fried chicken")
        
        XCTAssertEqual(recipe, stubbedRecipe)
    }
    
    func test_postRecipe_createsRecipeWithUserIdFromToken() async throws {
        let stubbedUserId = UUID()
        let store = RecipeStoreSpy(result: .success(anyRecipe()))
        let sut = makeSUT(store: store, tokenVerifier: { _ in stubbedUserId })
        
        let _ = try await sut.createRecipe(accessToken: "any valid access token", title: "Fried chicken")
        
        XCTAssertEqual(store.capturedMessages, [
            .init(userId: stubbedUserId, title: "Fried chicken")
        ])
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
            passwordHasher: { $0 },
            passwordVerifier: { _,_ in true }
        )
    }
    
    struct RecipeStoreStub: RecipeStore {
        let result: Result<Recipe, Error>
        
        func getRecipes() throws -> [Recipe] {
            fatalError("should never be called within test case context")
        }
        
        func createRecipe(userId: UUID, title: String) throws -> Recipe {
            try result.get()
        }
    }
    
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
        func findUser(byEmail email: String) throws -> User? {
            return nil
        }
        func createUser(id: UUID, email: String, hashedPassword: String) throws {
            
        }
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func anyRecipe() -> Recipe {
        Recipe(id: UUID(), userId: UUID(), title: "any-title")
    }
}
