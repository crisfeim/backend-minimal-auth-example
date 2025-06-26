import MinimalAuthExample
import Hummingbird
import HummingbirdTesting
import XCTest

final class AppTests: XCTestCase, @unchecked Sendable {
    
    override func setUp() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    func testApp() async throws {
        let userStoreURL = testSpecificURL().appendingPathComponent("users.json")
        let recipeStoreURL = testSpecificURL().appendingPathComponent("recipes.json")
        
        let app = await makeApp(
            configuration: .init(),
            userStoreURL: userStoreURL,
            recipeStoreURL: recipeStoreURL
        )
        
        try await app.test(.router) { client in
            try await assertPostRegisterSucceeds(client, email: "hi@crisfe.im", password: "123456")
            
            let token = try await assertPostLoginSucceeds(client, email: "hi@crisfe.im", password: "123456")
            
            let recipe = try await assertPostRecipeSucceeds(client, accessToken: token, request: CreateRecipeRequest(title: "Test recipe"))
            
            let recipes = try await assertGetRecipesSucceeds(client, accessToken: token)
            XCTAssertEqual(recipes, [recipe])
        }
    }
}
    
private extension AppTests {
    func assertPostRegisterSucceeds(_ client: TestClientProtocol, email: String, password: String, file: StaticString = #filePath, line: UInt = #line) async throws {
        
        try await client.execute(
            uri: "/register",
            method: .post,
            headers: [.init("Content-Type")!: "application/json"],
            body: try bufferFrom(RegisterRequest(email: email, password: password))
        ) { response in
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: response.body)
            XCTAssertFalse(tokenResponse.token.isEmpty, file: file, line: line)
            XCTAssertEqual(response.status, .ok, file: file, line: line)
        }
    }
    
    func assertPostLoginSucceeds(_ client: TestClientProtocol, email: String, password: String, file: StaticString = #filePath, line: UInt = #line) async throws -> String {
        try await client.execute(
            uri: "/login",
            method: .post,
            headers: [.init("Content-Type")!: "application/json"],
            body: try bufferFrom(LoginRequest(email: email, password: password))
        ) { response in
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: response.body)
            XCTAssertFalse(tokenResponse.token.isEmpty, file: file, line: line)
            XCTAssertEqual(response.status, .ok, file: file, line: line)
            return tokenResponse.token
        }
    }
    
    func assertPostRecipeSucceeds(_ client: TestClientProtocol, accessToken: String, request: CreateRecipeRequest, file: StaticString = #filePath, line: UInt = #line) async throws -> Recipe {
        try await client.execute(
            uri: "/recipes",
            method: .post,
            headers: [
                .init("Content-Type")!: "application/json",
                .init("Authorization")!: "Bearer \(accessToken)"
            ],
            body: try bufferFrom(request)
        ) { response in
            try JSONDecoder().decode(Recipe.self, from: response.body)
        }
    }
    
    func assertGetRecipesSucceeds(_ client: TestClientProtocol, accessToken: String, file: StaticString = #filePath, line: UInt = #line) async throws -> [Recipe] {
        try await client.execute(
            uri: "/recipes",
            method: .get,
            headers: [
                .init("Content-Type")!: "application/json",
                .init("Authorization")!: "Bearer \(accessToken)"
            ]
        ) { response in
            return try JSONDecoder().decode([Recipe].self, from: response.body)
        }
    }
}

extension AppTests {
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self))")
    }
}

private func bufferFrom<T: Encodable>(_ payload: T) throws -> ByteBuffer {
    let data = try JSONEncoder().encode(payload)
    var buffer = ByteBufferAllocator().buffer(capacity: data.count)
    buffer.writeBytes(data)
    return buffer
}
