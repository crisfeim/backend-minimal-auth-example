// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import Hummingbird
import JWTKit

public enum AppComposer {
    static public func execute(with configuration: ApplicationConfiguration, secretKey: HMACKey, userStore: UserStore, recipeStore: RecipeStore) async -> some ApplicationProtocol {
        
        let jwtKeyCollection = JWTKeyCollection()
        await jwtKeyCollection.add(
            hmac: secretKey,
            digestAlgorithm: .sha256,
            kid: JWKIdentifier("auth-jwt")
        )
        
        let tokenProvider = TokenProvider(kid: JWKIdentifier("auth-jwt"), jwtKeyCollection: jwtKeyCollection)
        let tokenVerifier = TokenVerifier(jwtKeyCollection: jwtKeyCollection)
        let passwordHasher = BCryptPasswordHasher()
        let passwordVerifier = BCryptPasswordVerifier()
        
        let emailValidator: EmailValidator = { _ in true }
        let passwordValidator: PasswordValidator = { _ in true }
        
    
        let registerController = RegisterController<UUID>(
            userMaker: { email, hashedPassword in
                try userStore.createUser(email: email, hashedPassword: hashedPassword)
            },
            userExists: { email in
               try userStore.findUser(byEmail: email) != nil
            },
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider.execute,
            passwordHasher: passwordHasher.execute
        ) |> RegisterControllerAdapter.init
         
        let loginController = LoginController<UUID>(
            userFinder: { email in
                return try userStore.findUser(byEmail: email).map {
                    .init(id: $0.id, hashedPassword: $0.hashedPassword)
                }
            },
            emailValidator: emailValidator,
            passwordValidator: passwordValidator,
            tokenProvider: tokenProvider.execute,
            passwordVerifier: passwordVerifier.execute
        ) |> LoginControllerAdapter.init
        
        let recipesController = RecipesControllerAdapter(RecipesController(store: recipeStore, tokenVerifier: tokenVerifier.execute))
        
        return Application(router: Router() .* { router in
            router.post("/register", use: registerController.handle)
            router.post("/login", use: loginController.handle)
            router.addRoutes(recipesController.endpoints, atPath: "/recipes")
        }, configuration: configuration )
    }
}


infix operator .*: AdditionPrecedence

/// Functional operator.
private func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}

precedencegroup PipePrecedence {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
}

infix operator |> : PipePrecedence
func |><A, B>(lhs: A, rhs: (A) -> B) -> B {
    rhs(lhs)
}
