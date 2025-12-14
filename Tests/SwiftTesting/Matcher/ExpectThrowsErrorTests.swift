#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectThrowsError Tests", .serialized)
struct ExpectThrowsErrorTests {
    fileprivate enum Error: Swift.Error {
        case one
        case two
    }

    @Test("Errors")
    func errors() {
        expectThrows(Error.one) {
            try throwError()
        }

        expectNoThrow {
            try notThrowError()
        }
    }
}

private func throwError() throws {
    throw ExpectThrowsErrorTests.Error.one
}

private func notThrowError() throws {
    // nothing
}
#endif // canImport(Testing)
