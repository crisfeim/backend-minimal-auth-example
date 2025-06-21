import Vapor

public func routes(_ app: Application, userStore: any UserStore) throws {
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
    
    app.post("login") { req async throws -> HTTPStatus in
        do {
            let data = try req.content.decode(LoginRequest.self)
            let _ = try userStore.findUser(byEmail: data.email)
            return .ok
        } catch {
            throw Abort(.internalServerError, reason: "Failed finding user")
        }
    }
}
