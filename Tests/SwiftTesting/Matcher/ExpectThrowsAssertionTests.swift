#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectThrowsAssertion Tests", .serialized)
struct ExpectThrowsAssertionTests {
    @Test("Assertion")
    func assertion() {
        expectThrowsAssertion {
            throwAssertion()
        }

        expectThrowsAssertion {
            throwFatalError()
        }

        expectThrowsAssertion {
            throwPrecondition()
        }
    }
}

private func throwAssertion() {
    assertionFailure()
}

private func throwFatalError() {
    fatalError()
}

private func throwPrecondition() {
    preconditionFailure()
}
#endif // canImport(Testing)
