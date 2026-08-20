import Foundation
import SpryKit
import XCTest

final class XCTAssertEqualErrorXCTests: XCTestCase {
    private enum Error: Swift.Error {
        case one
        case two
    }

    func test_errors() {
        XCTAssertEqualError(Error.one, Error.one)
        XCTAssertNotEqualError(Error.one, Error.two)

        XCTAssertEqualError(Error.one) {
            return Error.one
        }

        XCTAssertNotEqualError(Error.one) {
            return Error.two
        }
    }

    func test_a_nil_error_is_reported() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualError(Error.one, nil)
        }, issueMatcher: { $0.compactDescription.contains("expected error is nil") })

        XCTExpectFailure(failingBlock: {
            XCTAssertEqualError(nil, Error.one)
        }, issueMatcher: { $0.compactDescription.contains("actual error is nil") })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualError(Error.one, nil)
        }, issueMatcher: { $0.compactDescription.contains("expected error is nil") })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualError(nil, Error.one)
        }, issueMatcher: { $0.compactDescription.contains("actual error is nil") })
    }

    func test_unequal_errors_are_reported() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualError(Error.one, Error.two, "must match")
        }, issueMatcher: { $0.compactDescription.contains("must match") })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualError(Error.one, Error.one, "must differ")
        }, issueMatcher: { $0.compactDescription.contains("must differ") })
    }

    func test_reversed_overloads() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualError(Error.one) { nil }
        }, issueMatcher: { $0.compactDescription.contains("actual error is nil") })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualError(Error.one) { Error.one }
        }, issueMatcher: { _ in true })
    }
}
