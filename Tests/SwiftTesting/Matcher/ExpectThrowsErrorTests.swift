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

    @Test("Autoclosure overloads")
    func autoclosure_overloads() {
        try expectThrows(throwError(), Error.one)
        #expect(try expectNoThrow(notThrowValue()) == 7)
    }

    @Test("Expecting a throw that never happens is reported")
    func expecting_a_throw_that_never_happens_is_reported() {
        withKnownIssue {
            expectThrows(Error.one) {
                try notThrowError()
            }
        } matching: { issue in
            issue.description.contains("to be thrown, but expression completed successfully")
        }
    }

    @Test("A different error type is reported")
    func a_different_error_type_is_reported() {
        withKnownIssue {
            expectThrows(Error.one) {
                try throwOtherError()
            }
        } matching: { issue in
            issue.description.contains("but got")
        }
    }

    @Test("A different error case is reported")
    func a_different_error_case_is_reported() {
        withKnownIssue {
            expectThrows(Error.two) {
                try throwError()
            }
        }
    }

    @Test("An unexpected throw in expectNoThrow is reported")
    func an_unexpected_throw_in_expectNoThrow_is_reported() {
        var result: Int?
        withKnownIssue {
            result = expectNoThrow {
                try throwValue()
            }
        } matching: { issue in
            issue.description.contains("error:")
        }
        #expect(result == nil)
    }

    @Test("A custom message reaches the report")
    func a_custom_message_reaches_the_report() {
        withKnownIssue {
            expectThrows(Error.one, "must throw one") {
                try notThrowError()
            }
        } matching: { issue in
            issue.description.contains("must throw one")
        }
    }
}

private func throwError() throws {
    throw ExpectThrowsErrorTests.Error.one
}

private func notThrowError() throws {
    // nothing
}

private func notThrowValue() throws -> Int {
    return 7
}

private func throwValue() throws -> Int {
    throw ExpectThrowsErrorTests.Error.one
}

private struct OtherError: Swift.Error {}

private func throwOtherError() throws {
    throw OtherError()
}
#endif // canImport(Testing)
