import Vapor

func routes(_ app: Application, userStore: any UserStore) throws {
    app.post("register") { req async -> HTTPStatus in
        do {
            try userStore.saveUser(User(id: UUID(), email: ""))
            return .ok
        } catch {
            return .internalServerError
        }
    }
}
