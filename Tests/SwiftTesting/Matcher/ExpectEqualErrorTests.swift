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

    @Test("Unequal errors are reported")
    func unequal_errors_are_reported() {
        withKnownIssue {
            expectEqualError(Error.one, Error.two, "must match")
        } matching: { issue in
            issue.description.contains("must match")
        }

        withKnownIssue {
            expectNotEqualError(Error.one, Error.one, "must differ")
        } matching: { issue in
            issue.description.contains("must differ")
        }
    }

    @Test("The closure overloads report nil and unexpected throws")
    func the_closure_overloads_report_nil_and_unexpected_throws() {
        withKnownIssue {
            expectEqualError(Error.one) { nil }
        } matching: { issue in
            issue.description.contains("but actual error is nil")
        }

        withKnownIssue {
            expectNotEqualError(Error.one) { nil }
        } matching: { issue in
            issue.description.contains("but actual error is nil")
        }

        withKnownIssue {
            expectEqualError(Error.one) { throw Error.two }
        } matching: { issue in
            issue.description.contains("Unexpected error thrown")
        }

        withKnownIssue {
            expectNotEqualError(Error.one) { throw Error.two }
        } matching: { issue in
            issue.description.contains("Unexpected error thrown")
        }

        withKnownIssue {
            expectNotEqualError(Error.one) { Error.one }
        }
    }
}
#endif // canImport(Testing)
