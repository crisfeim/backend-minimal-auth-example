// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public protocol UserStore {
    func createUser(email: String, hashedPassword: String) throws -> UUID
    func findUser(byEmail email: String) throws -> User?
}
