import Foundation
import NSpry

final class SpryableTestClass: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case getAStaticString = "getAStaticString()"
    }

    static func getAStaticString() -> String {
        return spryify()
    }

    enum Function: String, StringRepresentable {
        case firstName
        case getAStringWithArguments = "getAString(string:)"
        case getAString = "getAString()"
    }

    var firstName: String {
        set {
            recordCall(arguments: newValue)
        }
        get {
            return stubbedValue()
        }
    }

    func getAString(string: String) -> String {
        return spryify(arguments: string)
    }

    func getAString() -> String {
        return spryify()
    }
}
