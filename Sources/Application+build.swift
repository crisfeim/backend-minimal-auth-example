// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation
import Hummingbird

func makeApp(configuration: ApplicationConfiguration) -> some ApplicationProtocol {
    let router = Router()
    router.get("/") { _, _ in
        return "Hello"
    }

    let app = Application(
        router: router,
        configuration: configuration
    )
    return app
}

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

import JWTKit

struct JWTPayloadData: JWTPayload, Equatable {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    // Define additional JWT Attributes here
    var email: String

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}


struct TokenProvider {
    let kid: JWKIdentifier
    let jwtKeyCollection: JWTKeyCollection
    
    func execute(userId: UUID, email: String) async throws -> String {
        let payload = JWTPayloadData(
            subject: .init(value: userId.uuidString),
            expiration: .init(value: Date(timeIntervalSinceNow: 12 * 60 * 60)),
            email: email
        )
        return try await self.jwtKeyCollection.sign(payload, kid: self.kid)
    }
}

import HummingbirdBcrypt
import NIOPosix

struct BCryptPasswordHasher {
    func execute(_ password: String) async throws -> String {
       return try await NIOThreadPool.singleton.runIfActive { Bcrypt.hash(password, cost: 12) }
    }
}


struct BCryptPasswordVerifier {
    func execute(_ password: String, _ hash: String) async throws -> Bool {
        try await NIOThreadPool.singleton.runIfActive {
            Bcrypt.verify(password, hash: hash)
        }
    }
}

struct TokenVerifier {
    let jwtKeyCollection: JWTKeyCollection

    func execute(_ token: String) async throws -> UUID {
        let payload = try await jwtKeyCollection.verify(token, as: JWTPayloadData.self)
        
        guard let uuid = UUID(uuidString: payload.subject.value) else {
            throw InvalidSubjectError()
        }
        return uuid
    }

    struct InvalidSubjectError: Error {}
}


import Foundation
import Hummingbird

enum ResponseGeneratorEncoder {
    static func execute<T: Encodable>(_ encodable: T, from request: Request, context: some RequestContext) throws -> Response {
        let data = try JSONEncoder().encode(encodable)
        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.writeBytes(data)
        
        var headers = HTTPFields()
        headers.reserveCapacity(4)
        headers.append(.init(name: .contentType, value: "application/json"))
        headers.append(.init(name: .contentLength, value: buffer.readableBytes.description))

        return Response(
            status: .ok,
            headers: headers,
            body: .init(byteBuffer: buffer)
        )
    }
}
