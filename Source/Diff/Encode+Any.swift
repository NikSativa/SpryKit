import Foundation

extension Spry {
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
            return "nil"
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
