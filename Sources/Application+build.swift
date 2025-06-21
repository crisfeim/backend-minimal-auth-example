// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

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
