import Foundation
import SpryKit

@Spryable
final class SpryableAsyncTestClass: @unchecked Sendable {
    @SpryableVar(.async, .throws)
    var remoteName: String

    @SpryableFunc
    func loadValue() async throws -> String

    @SpryableFunc
    func loadValue(key: String) async throws -> String

    @SpryableFunc
    func count() async -> Int

    @SpryableFunc
    func pause(seconds: Int) async throws

    @SpryableFunc
    func cachedValue() -> String

    @SpryableFunc
    class func loadShared() async throws -> String
}
