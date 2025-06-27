// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


public struct AuthRequest: Codable {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
