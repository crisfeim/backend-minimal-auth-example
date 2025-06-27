// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
import Foundation

public struct Recipe: Equatable, Codable {
    let id: UUID
    public let userId: UUID
    public let title: String
    
    public init(id: UUID, userId: UUID, title: String) {
        self.id = id
        self.userId = userId
        self.title = title
    }
}
