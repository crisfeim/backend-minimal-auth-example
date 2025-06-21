// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.

import Foundation

final class CodableStore<T: Codable> {
    let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func save(_ object: T) throws {
        var objects = try get()
        objects.append(object)
        let data = try JSONEncoder().encode(objects)
        try data.write(to: storeURL)
    }
    
    func get() throws -> [T] {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return [] }
        let data = try Data(contentsOf: storeURL)
        return try JSONDecoder().decode([T].self, from: data)
    }
}
