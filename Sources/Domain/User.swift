// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
import Foundation

public struct User: Equatable {
    public let id: UUID
    public let email: String
    public let hashedPassword: String
    
    public init(id: UUID, email: String, hashedPassword: String) {
        self.id = id
        self.email = email
        self.hashedPassword = hashedPassword
    }
}
