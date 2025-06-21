// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public protocol UserStore {
    func createUser(id: UUID, email: String, hashedPassword: String) throws
    func findUser(byEmail email: String) throws -> User?
}
