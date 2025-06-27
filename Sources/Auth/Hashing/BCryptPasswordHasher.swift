// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


import HummingbirdBcrypt
import NIOPosix

struct BCryptPasswordHasher {
    func execute(_ password: String) async throws -> String {
       return try await NIOThreadPool.singleton.runIfActive { Bcrypt.hash(password, cost: 12) }
    }
}
