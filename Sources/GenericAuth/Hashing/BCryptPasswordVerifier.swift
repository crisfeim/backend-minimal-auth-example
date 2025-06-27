// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import HummingbirdBcrypt
import NIOPosix

public struct BCryptPasswordVerifier {
    public init() {}
    public func execute(_ password: String, _ hash: String) async throws -> Bool {
        try await NIOThreadPool.singleton.runIfActive {
            Bcrypt.verify(password, hash: hash)
        }
    }
}
