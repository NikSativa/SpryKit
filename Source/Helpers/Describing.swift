import Foundation

#if swift(>=6.0)
public nonisolated(unsafe) var SpryJSONEncoderOutputFormatting: JSONEncoder.OutputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
#else
public var SpryJSONEncoderOutputFormatting: JSONEncoder.OutputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
#endif

internal func describe<T>(_ value: T?) -> String {
    let str: String
    switch value {
    case .none:
        str = "nil"
    case .some(let value):
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
