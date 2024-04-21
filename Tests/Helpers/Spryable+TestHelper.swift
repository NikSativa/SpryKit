import Foundation
import SpryKit

#if canImport(SwiftSyntax600) && swift(>=6.0)
@Spryable
final class SpryableTestClass: @unchecked Sendable {
    @SpryableFunc
    static func getAStaticString() -> String

    @SpryableVar(.set, .get)
    var firstName: String

    @SpryableFunc
    func getAString(string: String) -> String

    @SpryableFunc
    func getAString() -> String
}
#else
final class SpryableTestClass: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case getAStaticString = "getAStaticString()"
    }

    enum Function: String, StringRepresentable {
        case firstName_get = "firstName"
        case firstName_set = "firstName(_:)"
        case getAStringWithString = "getAString(string:)"
        case getAString = "getAString()"
    }

    static func getAStaticString() -> String {
        return spryify()
    }

    var firstName: String {
        get {
            return spryify("firstName_get")
        }
        set {
            return spryify("firstName_set", arguments: newValue)
        }
    }

    ///    #SpryableFunc
    func getAString(string: String) -> String {
        return spryify(arguments: string)
    }

    ///    #SpryableFunc
    func getAString() -> String {
        return spryify()
    }
}
#endif
