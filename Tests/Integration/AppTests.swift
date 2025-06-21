import MinimalAuthExample
import Hummingbird
import HummingbirdTesting
import XCTest

final class AppTests: XCTestCase {
    
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
        
        let registerPayload = try bufferFrom(RegisterRequest(email: "hi@crisfe.im", password: "123456"))
        let loginPayload = try bufferFrom(RegisterRequest(email: "hi@crisfe.im", password: "123456"))
        
        try await app.test(.router) { client in
            try await client.execute(
                uri: "/register",
                method: .post,
                headers: [.init("Content-Type")!: "application/json"],
                body: registerPayload
            ) { response in

                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: response.body)
                XCTAssertFalse(tokenResponse.token.isEmpty)
                XCTAssertEqual(response.status, .ok)
            }
            
            try await client.execute(
                uri: "/login",
                method: .post,
                headers: [.init("Content-Type")!: "application/json"],
                body: loginPayload
            ) { response in

                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: response.body)
                XCTAssertFalse(tokenResponse.token.isEmpty)
                XCTAssertEqual(response.status, .ok)
            }
        }
    }
    
    func bufferFrom<T: Encodable>(_ payload: T) throws -> ByteBuffer {
        let data = try JSONEncoder().encode(payload)
        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.writeBytes(data)
        return buffer
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self))")
    }
}
