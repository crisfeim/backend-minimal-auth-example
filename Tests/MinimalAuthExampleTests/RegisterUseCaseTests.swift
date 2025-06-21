import MinimalAuthExample
import VaporTesting
import Testing

import JWT
import Vapor




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
    
    @Test("Register delivers token on success")
    func postRegister_deliversTokenOnSuccessfulRegistration() async throws {
        let store = UserStoreSpy()
        try await withApp(configure: configure(userStore: store)) { app in
            let body = RegisterRequest(email: "test@example.com", password: "123456")
            let buffer = try body.encodeToByteBuffer(using: app.allocator)

            try await app.testing().test(
                .POST,
                "register",
                headers: ["Content-Type": "application/json"],
                body: buffer
            ) { res async throws in
                let token = try? res.content.decode(TokenResponse.self)
                #expect(token != nil)
            }
        }
    }
    
    @Test("Register returns valid token with correct user data")
    func postRegister_deliversCorrectTokenOnSuccessfulRegistration() async throws {
        let store = UserStoreSpy()

        try await withApp(configure: configure(userStore: store)) { app in
            let body = RegisterRequest(email: "test@example.com", password: "123456")
            let buffer = try body.encodeToByteBuffer(using: app.allocator)

            try await app.testing().test(
                .POST,
                "register",
                headers: ["Content-Type": "application/json"],
                body: buffer
            ) { res async throws in
                
                let token = try res.content.decode(TokenResponse.self).token
                
                let fakeReq = Request(application: app, on: app.eventLoopGroup.next())
                let payload = try await fakeReq.jwt.verify(token, as: UserJWTPayload.self)
                
                #expect(payload.email == "test@example.com")
                #expect(UUID(uuidString: payload.sub.value) != nil)
            }
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
      try await configure(app, userStore: userStore)
    }
}

