import Foundation

// MARK: - Data.spry

public extension Data {
    enum spry {
        // namespace
    }
}

public extension Data.spry {
    static func testMake(from obj: some Encodable,
                         encoder: JSONEncoder = .init()) throws -> Data {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(obj)
    }

    static func testMake<T: Decodable>(_ type: T.Type = T.self,
                                       from data: Data,
                                       decoder: JSONDecoder = .init()) throws -> T {
        return try decoder.decode(type, from: data)
    }
}
