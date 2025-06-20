import Vapor


public func configure(_ app: Application, userStore: any UserStore) async throws {
    try routes(app, userStore: userStore)
}
