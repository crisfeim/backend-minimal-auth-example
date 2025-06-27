// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


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
