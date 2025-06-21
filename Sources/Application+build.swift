// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import Hummingbird

func makeApp(configuration: ApplicationConfiguration) -> some ApplicationProtocol {
    let router = Router()
    router.get("/") { _, _ in
        return "Hello"
    }

    let app = Application(
        router: router,
        configuration: configuration
    )
    return app
}

func makeApp(configuration: ApplicationConfiguration, userStoreURL: URL, recipeStoreURL: URL) async -> some ApplicationProtocol {
    
    
    let jwtKeyCollection = JWTKeyCollection()
    await jwtKeyCollection.add(
        hmac: "my-secret-key",
        digestAlgorithm: .sha256,
        kid: JWKIdentifier("auth-jwt")
    )
    
    let tokenProvider = TokenProvider(kid: JWKIdentifier("auth-jwt"), jwtKeyCollection: jwtKeyCollection)
    
    let coordinator = RecipesApp(
        userStore: CodableUserStore(storeURL: userStoreURL),
        recipeStore: CodableRecipeStore(storeURL: recipeStoreURL),
        emailValidator: { _ in true },
        passwordValidator: { _ in true },
        tokenProvider:  tokenProvider.makeToken,
        tokenVerifier: { _ in UUID() },
        passwordHasher: { _ in "@todo" },
        passwordVerifier: { _,_ in true }
    )
    
    let router = Router()
    router.get("/") { _, _ in
        return "Hello"
    }

    let app = Application(
        router: router,
        configuration: configuration
    )
    return app
}

import JWTKit

struct JWTPayloadData: JWTPayload, Equatable {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    // Define additional JWT Attributes here
    var email: String

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}


struct TokenProvider {
    let kid: JWKIdentifier
    let jwtKeyCollection: JWTKeyCollection
    
    func makeToken(userId: UUID, email: String) async throws -> String {
        let payload = JWTPayloadData(
            subject: .init(value: userId.uuidString),
            expiration: .init(value: Date(timeIntervalSinceNow: 12 * 60 * 60)),
            email: email
        )
        return try await self.jwtKeyCollection.sign(payload, kid: self.kid)
    }
}
