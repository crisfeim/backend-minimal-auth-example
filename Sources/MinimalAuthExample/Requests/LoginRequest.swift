// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Vapor

public struct LoginRequest: Content {
    let email: String
    let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
