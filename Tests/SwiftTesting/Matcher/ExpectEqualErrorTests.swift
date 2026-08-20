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

    @Test("A nil error is reported at the call site")
    func a_nil_error_is_reported_at_the_call_site() {
        withKnownIssue {
            expectEqualError(Error.one, nil)
        } matching: { issue in
            issue.sourceLocation?.fileName == "ExpectEqualErrorTests.swift"
        }

        withKnownIssue {
            expectEqualError(nil, Error.one)
        } matching: { issue in
            issue.sourceLocation?.fileName == "ExpectEqualErrorTests.swift"
        }

        withKnownIssue {
            expectNotEqualError(Error.one, nil)
        } matching: { issue in
            issue.sourceLocation?.fileName == "ExpectEqualErrorTests.swift"
        }
    }
}
#endif // canImport(Testing)
