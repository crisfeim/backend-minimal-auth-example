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
    
    let emailValidator: EmailValidator = { _ in true }
    let passwordValidator: PasswordValidator = { _ in true }
    
    let userStore = CodableUserStore(storeURL: userStoreURL)
    
    let registerController = RegisterControllerAdapter(RegisterController(userStore: userStore, emailValidator: emailValidator, passwordValidator: passwordValidator, tokenProvider: tokenProvider.execute, passwordHasher: passwordHasher.execute))
    
    let loginController = LoginControllerAdapter(LoginController(userStore: userStore, emailValidator: emailValidator, passwordValidator: passwordValidator, tokenProvider: tokenProvider.execute, passwordVerifier: passwordVerifier.execute))
    
    let recipesController = RecipesControllerAdapter(RecipesController(store:  CodableRecipeStore(storeURL: recipeStoreURL), tokenVerifier: tokenVerifier.execute))
    
    return Application(router: Router() .* { router in
        router.post("/register", use: registerController.handle)
        router.post("/login", use: loginController.handle)
        router.addRoutes(recipesController.endpoints, atPath: "/recipes")
    }, configuration: configuration )
}


struct RegisterControllerAdapter: @unchecked Sendable {
    let controller: RegisterController
    
    init(_ controller: RegisterController) {
        self.controller = controller
    }
    
    func handle(request: Request, context: BasicRequestContext) async throws  -> Response {
        let registerRequest = try await request.decode(as: RegisterRequest.self, context: context)
        let token = try await controller.register(email: registerRequest.email, password: registerRequest.password)
        
        return try ResponseGeneratorEncoder.execute(
            TokenResponse(token: token),
            from: request,
            context: context
        )
    }
}

infix operator .*: AdditionPrecedence

func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}

struct LoginControllerAdapter: @unchecked Sendable   {
    let controller: LoginController
    
    init(_ controller: LoginController) {
        self.controller = controller
    }
    
    func handle(request: Request, context: BasicRequestContext) async throws  -> Response {
        let registerRequest = try await request.decode(as: LoginRequest.self, context: context)
        let token = try await controller.login(
            email: registerRequest.email,
            password: registerRequest.password
        )
        return try ResponseGeneratorEncoder.execute(
            TokenResponse(token: token),
            from: request,
            context: context
        )
    }
}

import Hummingbird

struct RecipesControllerAdapter: @unchecked Sendable {
    let controller: RecipesController
    
    init(_ controller: RecipesController) {
        self.controller = controller
    }
    
    var endpoints: RouteCollection<BasicRequestContext> {
        return RouteCollection(context: BasicRequestContext.self)
            .get(use: get)
            .post(use: post)
    }
    
    func post(request: Request, context: BasicRequestContext) async throws -> Response {
        guard let authHeader = request.headers[values: .init("Authorization")!].first,
              authHeader.starts(with: "Bearer "),
              let token = authHeader.split(separator: " ").last.map(String.init)
        else {
            return Response(status: .unauthorized)
        }
        
        let recipeRequest = try await request.decode(as: CreateRecipeRequest.self, context: context)
        let recipe = try await controller.postRecipe(accessToken: token, title: recipeRequest.title)
        return try ResponseGeneratorEncoder.execute(recipe, from: request, context: context)
    }
    
    func get(request: Request, context: BasicRequestContext) async throws -> Response {
        guard let authHeader = request.headers[values: .init("Authorization")!].first,
              authHeader.starts(with: "Bearer "),
              let token = authHeader.split(separator: " ").last.map(String.init)
        else {
            return Response(status: .unauthorized)
        }
        let recipes = try await controller.getRecipes(accessToken: token)
        return try ResponseGeneratorEncoder.execute(recipes, from: request, context: context)
    }
}
