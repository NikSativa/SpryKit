import Foundation
import SpryKit
import XCTest

final class XCTAssertEqualAnyXCTests: XCTestCase {
    private enum Error: Swift.Error {
        case one
        case two
    }

    func test_errors() {
        XCTAssertEqualAny(1, 1)
        XCTAssertEqualAny([1], [1])

        XCTAssertNotEqualAny(2, 1)
        XCTAssertNotEqualAny([2: 1], [1: 1])
    }

    func test_failure_message_describes_both_sides_and_the_diff() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualAny(EncodablePayload(name: "John"), EncodablePayload(name: "Jane"))
        }, issueMatcher: { issue in
            let text = issue.compactDescription
            return text.contains("\"name\" : \"John\"")
                && text.contains("\"name\" : \"Jane\"")
                && text.contains("is not equal to")
                && text.contains("diff:")
                && text.contains("Received: Jane")
        })
    }

    func test_failure_message_falls_back_to_a_plain_description() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualAny(PlainPayload(name: "John"), PlainPayload(name: "Jane"))
        }, issueMatcher: { issue in
            let text = issue.compactDescription
            return text.contains("PlainPayload(name: \"John\")") && text.contains("PlainPayload(name: \"Jane\")")
        })
    }

    func test_failure_message_describes_nil() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualAny(nil as Int?, 5)
        }, issueMatcher: { issue in
            let text = issue.compactDescription
            return text.contains("(\"nil\")") && text.contains("(\"5\")")
        })
    }

    func test_a_custom_message_replaces_the_generated_one() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualAny(1, 2, "values must match")
        }, issueMatcher: { issue in
            let text = issue.compactDescription
            return text.contains("values must match") && !text.contains("diff:")
        })
    }

    func test_not_equal_failure_reports_equality() {
        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualAny(1, 1)
        }, issueMatcher: { $0.compactDescription.contains("is equal to") })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualAny(1, 1, "values must differ")
        }, issueMatcher: { $0.compactDescription.contains("values must differ") })
    }
}

private struct EncodablePayload: Encodable {
    let name: String
}

private struct PlainPayload {
    let name: String
}
