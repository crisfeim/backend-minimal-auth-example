// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import Hummingbird
import JWTKit

public func makeApp(configuration: ApplicationConfiguration, userStoreURL: URL, recipeStoreURL: URL) async -> some ApplicationProtocol {
    
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
    
    let coordinator = RecipesApp(
        userStore: CodableUserStore(storeURL: userStoreURL),
        recipeStore: CodableRecipeStore(storeURL: recipeStoreURL),
        emailValidator: { _ in true },
        passwordValidator: { _ in true },
        tokenProvider:  tokenProvider.execute,
        tokenVerifier: tokenVerifier.execute,
        passwordHasher: passwordHasher.execute,
        passwordVerifier: passwordVerifier.execute
    )
    
    let router = Router()
    router.post("/register") {
        request,
        context in
        let registerRequest = try await request.decode(as: RegisterRequest.self, context: context)
        let result = try await coordinator.register(
            email: registerRequest.email,
            password: registerRequest.password
        )
        return try ResponseGeneratorEncoder.execute(
            TokenResponse(token: result["token"]!),
            from: request,
            context: context
        )
    }
    
    router.post("/login") { request, context in
        let registerRequest = try await request.decode(as: LoginRequest.self, context: context)
        let result = try await coordinator.login(
            email: registerRequest.email,
            password: registerRequest.password
        )
        return try ResponseGeneratorEncoder.execute(
            TokenResponse(token: result["token"]!),
            from: request,
            context: context
        )
    }
    
    router.post("/recipes") { request, context in
        guard let authHeader = request.headers[values: .init("Authorization")!].first,
              authHeader.starts(with: "Bearer "),
              let token = authHeader.split(separator: " ").last.map(String.init)
        else {
            return Response(status: .unauthorized)
        }
        
        let recipeRequest = try await request.decode(as: CreateRecipeRequest.self, context: context)
        
        let recipe = try await coordinator.createRecipe(
            accessToken: token,
            title: recipeRequest.title
        )
        
        return try ResponseGeneratorEncoder.execute(recipe, from: request, context: context)
    }
    
    router.get("/recipes") {
        request,
        context in
        guard let authHeader = request.headers[values: .init("Authorization")!].first,
              authHeader.starts(with: "Bearer "),
              let token = authHeader.split(separator: " ").last.map(String.init)
        else {
            return Response(status: .unauthorized)
        }
        
        return try await ResponseGeneratorEncoder.execute(
            try coordinator.getRecipes(accessToken: token),
            from: request,
            context: context
        )
        
    }

    let app = Application(
        router: router,
        configuration: configuration
    )
    return app
}

