// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
import Foundation

public struct User: Equatable {
    let id: UUID
    let email: String
    
    public init(id: UUID, email: String) {
        self.id = id
        self.email = email
    }
}
