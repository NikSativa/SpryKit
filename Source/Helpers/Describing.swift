import Foundation
import Threading

/// Output formatting used when SpryKit renders an `Encodable` value in a failure message.
public var SpryJSONEncoderOutputFormatting: JSONEncoder.OutputFormatting {
    get {
        return outputFormattingStorage.wrappedValue
    }
    set {
        outputFormattingStorage.wrappedValue = newValue
    }
}

private let outputFormattingStorage: AtomicValue<JSONEncoder.OutputFormatting> = .init(wrappedValue: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])

internal func describe<T>(_ value: T?) -> String {
    let str: String
    switch value {
    case .none:
        str = "nil"
    case let .some(value):
        if let value = value as? Encodable {
            let encoder = JSONEncoder()
            encoder.outputFormatting = SpryJSONEncoderOutputFormatting
            str = (try? String(data: encoder.encode(value), encoding: .utf8)) ?? String(describing: value)
        } else {
            str = String(describing: value)
        }
    }

    return "(\"" + str + "\")"
}
