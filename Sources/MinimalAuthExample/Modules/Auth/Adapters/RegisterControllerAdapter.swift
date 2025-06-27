// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.

import Foundation
import Hummingbird
import GenericAuth

struct RegisterControllerAdapter: @unchecked Sendable {
    let controller: RegisterController<UUID>
    
    init(_ controller: RegisterController<UUID>) {
        self.controller = controller
    }
    
    func handle(request: Request, context: BasicRequestContext) async throws  -> Response {
        let registerRequest = try await request.decode(as: AuthRequest.self, context: context)
        let token = try await controller.register(email: registerRequest.email, password: registerRequest.password)
        
        return try ResponseGeneratorEncoder.execute(
            TokenResponse(token: token),
            from: request,
            context: context
        )
    }
}
