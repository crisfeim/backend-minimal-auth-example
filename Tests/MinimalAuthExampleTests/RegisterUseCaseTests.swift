import MinimalAuthExample
import VaporTesting
import Testing


@Suite("Register Use Case Tests")
struct RegisterUseCaseTests {
    @Test("Test delivers internal server error on store error")
    func postRegister_deliversInternalServerErrorOnUserStoreError() async throws {
        let store = AlwaysFailingUserStore()
        
        try await withApp(configure: configure(userStore: store)) { app in
            let registerBody = RegisterRequest(email: "test@example.com", password: "123456")
            let buffer = try registerBody.encodeToByteBuffer(using: app.allocator)
            
            try await app.testing().test(.POST, "register", body: buffer, afterResponse: { res async in
                #expect(res.status == .internalServerError)
            })
        }
    }
    
    @Test("Test delivers delivers no error and request user saving on store success")
    func postRegister_deliversNoErrorAndPassesRequestedUserToUserStoreOnUserStoreSuccess() async throws {
        let store = UserStoreSpy()
        try await withApp(configure: configure(userStore: store)) { app in
            let registerBody = RegisterRequest(email: "test@example.com", password: "123456")
            let buffer = try registerBody.encodeToByteBuffer(using: app.allocator)
            
            try await app.testing().test(
                .POST,
                "register",
                headers: ["Content-Type": "application/json"],
                body: buffer,
                afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(store.capturedUsers.first?.email == "test@example.com")
            })
        }
    }
    
}

// MARK: - Test doubles
extension RegisterUseCaseTests {
    struct AlwaysFailingUserStore: UserStore {
        func findUser(byEmail email: String) throws -> User? {
            throw NSError(domain: "any error", code: 0)
        }
        
        func saveUser(_ user: User) throws {
            throw NSError(domain: "any error", code: 0)
        }
    }
    
    class UserStoreSpy: UserStore {
        var capturedUsers = [User]()
        
        func findUser(byEmail email: String) throws -> User? {
            nil
        }
        
        func saveUser(_ user: User) throws {
            capturedUsers.append(user)
        }
    }
}


// MARK: - Configure custom method
typealias Configure = (Application) async throws -> Void

func configure(userStore: any UserStore) -> Configure {
    return { app in
        try routes(app, userStore: userStore)
    }
}

