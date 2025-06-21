// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import JWT
import Vapor

public struct UserJWTPayload: JWTPayload {
    public let sub: SubjectClaim
    public let exp: ExpirationClaim
    public let email: String

    public func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.exp.verifyNotExpired()
    }
}
