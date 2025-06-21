// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
import Foundation

public struct Recipe: Equatable {
    let id: UUID
    let userId: UUID
    
    public init(id: UUID, userId: UUID) {
        self.id = id
        self.userId = userId
    }
}
