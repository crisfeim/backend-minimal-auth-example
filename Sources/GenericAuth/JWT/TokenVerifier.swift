// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import JWTKit

public struct TokenVerifier {
    private let jwtKeyCollection: JWTKeyCollection
    
    public init(jwtKeyCollection: JWTKeyCollection) {
        self.jwtKeyCollection = jwtKeyCollection
    }

    public func execute(_ token: String) async throws -> UUID {
        let payload = try await jwtKeyCollection.verify(token, as: JWTPayloadData.self)
        
        guard let uuid = UUID(uuidString: payload.subject.value) else {
            throw InvalidSubjectError()
        }
        return uuid
    }

    struct InvalidSubjectError: Error {}
}
