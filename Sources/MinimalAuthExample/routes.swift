import Vapor

func routes(_ app: Application, userStore: any UserStore) throws {
    app.post("register") { req async throws -> HTTPStatus in
        do {
            let data = try req.content.decode(RegisterRequest.self)
            let user = User(id: UUID(), email: data.email, hashedPassword: data.password)
            try userStore.saveUser(user)
            return .ok
        } catch {
            throw Abort(.internalServerError, reason: "Failed to save user")
        }
    }
}
