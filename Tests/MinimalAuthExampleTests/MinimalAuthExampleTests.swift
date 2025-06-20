@testable import MinimalAuthExample
import VaporTesting
import Testing


struct RegisterRequest: Content {
    let email: String
    let password: String
}

import Vapor

extension Encodable {
    func encodeToByteBuffer(using allocator: ByteBufferAllocator) throws -> ByteBuffer {
        let data = try JSONEncoder().encode(self)
        var buffer = allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        return buffer
    }
}

@Suite("App Tests")
struct MinimalAuthExampleTests {
    @Test("Test delivers registration error on store failure")
    func deliversRegistrationErrorOnStoreFailure() async throws {
        let store = AlwaysFailingUserStore()

        try await withApp(configure: configure(userStore: store)) { app in
            let registerBody = RegisterRequest(email: "test@example.com", password: "123456")
            let buffer = try registerBody.encodeToByteBuffer(using: app.allocator)
            
            try await app.testing().test(.POST, "register", body: buffer, afterResponse: { res async in
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

typealias Configure = (Application) async throws -> Void

func configure(userStore: any UserStore) -> Configure {
    return { app in
        try routes(app, userStore: userStore)
    }
}

