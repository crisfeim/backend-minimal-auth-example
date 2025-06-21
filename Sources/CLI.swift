// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import ArgumentParser
import Foundation

@main
struct CLI: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    func run() async throws {
        let userStoreURL = appDataURL().appendingPathComponent("users.json")
        let recipeStoreURL = appDataURL().appendingPathComponent("recipes.json")
        let app = await makeApp(
            configuration: .init(
                address: .hostname(self.hostname, port: self.port),
                serverName: "Hummingbird"
            ),
            userStoreURL: userStoreURL,
            recipeStoreURL: recipeStoreURL
        )
        try await app.runService()
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func appDataURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self))")
    }
}
