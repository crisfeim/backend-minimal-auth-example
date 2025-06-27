// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import JWTKit

public struct TokenProvider {
    private let kid: JWKIdentifier
    private let jwtKeyCollection: JWTKeyCollection
    
    public init(kid: JWKIdentifier, jwtKeyCollection: JWTKeyCollection) {
        self.kid = kid
        self.jwtKeyCollection = jwtKeyCollection
    }
    
    public func execute(userId: UUID, email: String) async throws -> String {
        let payload = JWTPayloadData(
            subject: .init(value: userId.uuidString),
            expiration: .init(value: Date(timeIntervalSinceNow: 12 * 60 * 60)),
            email: email
        )
        return try await self.jwtKeyCollection.sign(payload, kid: self.kid)
    }
}
