#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectEqualAny Tests", .serialized)
struct ExpectEqualAnyTests {
    private enum Error: Swift.Error {
        case one
        case two
    }

    @Test("Errors")
    func errors() {
        expectEqualAny(1, 1)
        expectEqualAny([1], [1])

        expectNotEqualAny(2, 1)
        expectNotEqualAny([2: 1], [1: 1])
    }
}
#endif // canImport(Testing)
