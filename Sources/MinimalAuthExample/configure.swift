import Vapor
import JWT


public func configure(_ app: Application, userStore: any UserStore) async throws {
    await app.jwt.keys.add(hmac: "secret", digestAlgorithm: .sha256)
    try routes(app, userStore: userStore)
}
