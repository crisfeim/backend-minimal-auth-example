// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

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
