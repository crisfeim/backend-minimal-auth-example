// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


import HummingbirdBcrypt
import NIOPosix

public struct BCryptPasswordHasher {
    public init() {}
    public func execute(_ password: String) async throws -> String {
       return try await NIOThreadPool.singleton.runIfActive { Bcrypt.hash(password, cost: 12) }
    }
}
