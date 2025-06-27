// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


public struct LoginRequest: Codable {
    let email: String
    let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
