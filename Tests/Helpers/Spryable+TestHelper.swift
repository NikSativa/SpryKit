import Foundation
import SpryKit

@Spryable
final class SpryableTestClass: @unchecked Sendable {
    @SpryableFunc
    static func getAStaticString() -> String

    @SpryableVar(.set)
    var firstName: String

    @SpryableFunc
    func getAString(string: String) -> String

    @SpryableFunc
    func getAString() -> String
}
