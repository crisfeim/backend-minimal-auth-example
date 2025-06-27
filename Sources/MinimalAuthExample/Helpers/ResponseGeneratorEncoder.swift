// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


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
