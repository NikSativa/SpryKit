#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectEqualError Tests", .serialized)
struct ExpectEqualErrorTests {
    private enum Error: Swift.Error {
        case one
        case two
    }

    @Test("Errors")
    func errors() {
        expectEqualError(Error.one, Error.one)
        expectNotEqualError(Error.one, Error.two)

        expectEqualError(Error.one) {
            Error.one
        }

        expectNotEqualError(Error.one) {
            Error.two
        }
    }
}
#endif // canImport(Testing)
