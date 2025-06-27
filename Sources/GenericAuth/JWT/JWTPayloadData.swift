// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


import JWTKit

public struct JWTPayloadData: JWTPayload, Equatable {
    var subject: SubjectClaim
    private var expiration: ExpirationClaim
    private var email: String
    
    public init(subject: SubjectClaim, expiration: ExpirationClaim, email: String) {
        self.subject = subject
        self.expiration = expiration
        self.email = email
    }

    public func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}
