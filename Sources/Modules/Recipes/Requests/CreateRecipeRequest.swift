// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

public struct CreateRecipeRequest: Codable {
    let title: String
    public init(title: String) {
        self.title = title
    }
}
