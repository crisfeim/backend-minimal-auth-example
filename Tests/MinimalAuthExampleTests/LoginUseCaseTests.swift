// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

@testable import MinimalAuthExample
import VaporTesting
import Testing

@Suite("App Tests")
struct LoginUseCaseTests {
    
    @Test("Login delivers error on user store error")
    func loginDeliverErrorOnUserStoreError() async throws {
        let store = AlwaysFailingUserStore()
        
        try await withApp(configure: configure(userStore: store)) { app in
            let registerBody = LoginRequest(email: "test@example.com", password: "123456")
            let buffer = try registerBody.encodeToByteBuffer(using: app.allocator)
            try await app.testing().test(
                .POST,
                "login",
                headers: ["Content-Type": "application/json"],
                body: buffer,
                afterResponse: { res async in
                #expect(res.status == .internalServerError)
            })
        }
    }
    
    struct AlwaysFailingUserStore: UserStore {
        func findUser(byEmail email: String) throws -> User? {
            throw NSError(domain: "any error", code: 0)
        }
        
        func saveUser(_ user: User) throws {
            throw NSError(domain: "any error", code: 0)
        }
    }
    
}
