// © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.


// MARK: - Encodable
import Vapor

extension Encodable {
    func encodeToByteBuffer(using allocator: ByteBufferAllocator) throws -> ByteBuffer {
        let data = try JSONEncoder().encode(self)
        var buffer = allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        return buffer
    }
}
