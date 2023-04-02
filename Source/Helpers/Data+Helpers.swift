import Foundation

// MARK: - Data.spry

public extension Data {
    enum spry {
        // namespace
    }
}

public extension Data.spry {
    static func testMake(from obj: some Encodable,
                         encoder: JSONEncoder? = nil) throws -> Data {
        let encoder = encoder ?? {
            let new = JSONEncoder()
            new.outputFormatting = [.prettyPrinted, .sortedKeys]
            return new
        }()
        return try encoder.encode(obj)
    }

    static func testMake<T: Decodable>(_ type: T.Type = T.self,
                                       from data: Data,
                                       decoder: JSONDecoder? = nil) throws -> T {
        let decoder = decoder ?? JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}
