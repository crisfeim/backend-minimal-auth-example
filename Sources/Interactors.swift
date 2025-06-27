// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

public typealias EmailValidator  = (_ email: String) -> Bool
public typealias PasswordValidator = (_ password: String) -> Bool
public typealias AuthTokenProvider = (_ userId: UUID, _ email: String) async throws -> String
public typealias AuthTokenVerifier = (_ token: String) async throws -> UUID
public typealias PasswordHasher = (_ input: String) async throws -> String
public typealias PasswordVerifier = (_ password: String, _ hash: String) async throws -> Bool
