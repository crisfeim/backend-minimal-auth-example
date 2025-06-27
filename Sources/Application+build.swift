// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import Hummingbird
import JWTKit

public func makeApp(configuration: ApplicationConfiguration, userStore: UserStore, recipeStore: RecipeStore) async -> some ApplicationProtocol {
    
    let jwtKeyCollection = JWTKeyCollection()
    await jwtKeyCollection.add(
        hmac: "my-secret-key",
        digestAlgorithm: .sha256,
        kid: JWKIdentifier("auth-jwt")
    )
    
    let tokenProvider = TokenProvider(kid: JWKIdentifier("auth-jwt"), jwtKeyCollection: jwtKeyCollection)
    let tokenVerifier = TokenVerifier(jwtKeyCollection: jwtKeyCollection)
    let passwordHasher = BCryptPasswordHasher()
    let passwordVerifier = BCryptPasswordVerifier()
    
    let emailValidator: EmailValidator = { _ in true }
    let passwordValidator: PasswordValidator = { _ in true }
    
    
    let registerController = RegisterControllerAdapter(RegisterController(userStore: userStore, emailValidator: emailValidator, passwordValidator: passwordValidator, tokenProvider: tokenProvider.execute, passwordHasher: passwordHasher.execute))
    
    let loginController = LoginControllerAdapter(LoginController(userStore: userStore, emailValidator: emailValidator, passwordValidator: passwordValidator, tokenProvider: tokenProvider.execute, passwordVerifier: passwordVerifier.execute))
    
    let recipesController = RecipesControllerAdapter(RecipesController(store: recipeStore, tokenVerifier: tokenVerifier.execute))
    
    return Application(router: Router() .* { router in
        router.post("/register", use: registerController.handle)
        router.post("/login", use: loginController.handle)
        router.addRoutes(recipesController.endpoints, atPath: "/recipes")
    }, configuration: configuration )
}




