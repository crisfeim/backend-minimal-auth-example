// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
import Foundation

public struct User: Equatable {
    let id: UUID
    
    public init(id: UUID) {
        self.id = id
    }
}
