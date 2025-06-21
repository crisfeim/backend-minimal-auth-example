import Vapor

public func routes(_ app: Application, userStore: any UserStore) throws {
    app.post("register") { req async throws -> TokenResponse in
        do {
            let data = try req.content.decode(RegisterRequest.self)
            let user = User(id: UUID(), email: data.email, hashedPassword: data.password)
            
            let payload = UserJWTPayload(
                sub: .init(value: user.id.uuidString),
                exp: .init(value: .init(timeIntervalSinceNow: 3600)),
                email: user.email
            )
            
            try userStore.saveUser(user)
            let token = try await req.jwt.sign(payload)
            return TokenResponse(token: token)
        } catch {
            print("Error on register", error)
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
