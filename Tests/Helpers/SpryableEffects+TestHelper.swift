import Foundation
import SpryKit

@Spryable
final class SpryableEffectsTestClass: @unchecked Sendable {
    @SpryableFunc
    class func classScoped(some: Int) -> String

    @SpryableVar(.throws)
    var throwingName: String

    @SpryableFunc
    func loadAString() throws -> String

    @SpryableFunc
    func rethrowing<R>(execute work: @escaping () throws -> R) rethrows -> R

    @SpryableFunc(.asArgument)
    func observe(changes: @escaping (Int) -> Void)
}
