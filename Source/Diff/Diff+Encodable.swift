import Foundation

public extension Spry {
    /// Builds line-by-line diff between two Encodable values.
    ///
    /// Values are encoded to JSON strings using the provided encoder and then compared line-by-line.
    ///
    /// ## Examples ##
    /// ```swift
    /// struct User: Encodable {
    ///     let id: Int
    ///     let name: String
    /// }
    /// let diff = Spry.diffEncodable(user1, user2)
    /// // Values are serialized to JSON and compared line-by-line
    /// ```
    ///
    /// - Parameters:
    ///   - first: First Encodable value to compare
    ///   - second: Second Encodable value to compare
    ///   - encoder: JSONEncoder to use for encoding (defaults to new instance)
    /// - Returns: Diff string with line markers, or empty string if values are equal
    static func diffEncodable<T: Encodable>(_ first: T?, _ second: T?, encoder: @autoclosure () -> JSONEncoder = .init()) -> String {
        let lhs = encode(first, encoder: encoder())
        let rhs = encode(second, encoder: encoder())
        return String.spry.diffLines(lhs, rhs)
    }
}

private extension Spry {
    static func encode<T>(_ value: T?, encoder: @autoclosure () -> JSONEncoder = .init()) -> String {
        if let value = value as? String {
            return value
        }

        var prettyEncoder: JSONEncoder {
            let encoder = encoder()
            var outputFormatting = encoder.outputFormatting
            outputFormatting.insert(.sortedKeys)
            outputFormatting.insert(.withoutEscapingSlashes)
            outputFormatting.insert(.prettyPrinted)
            encoder.outputFormatting = outputFormatting
            return encoder
        }

        switch value {
        case .none:
            return "null"
        case .some(let value):
            if let value = value as? Encodable {
                if let str = (try? String(data: prettyEncoder.encode(value), encoding: .utf8)) {
                    return str
                }
            }
            return String(describing: value)
        }
    }
}
