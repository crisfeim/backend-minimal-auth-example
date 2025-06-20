// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

protocol UserStore {
    func saveUser(_ user: User) throws
    func findUser(byEmail email: String) throws -> User?
}
