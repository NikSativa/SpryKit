import Foundation
import SpryKit
import XCTest

final class StringRepresentableXCTests: XCTestCase {
    func test_an_exact_signature_resolves_directly() {
        let subject = Signatures(functionName: "plain()", type: Self.self, file: #file, line: #line)

        XCTAssertEqual(subject, .plain)
    }

    func test_a_single_unnamed_argument_suffix_is_dropped_when_the_case_has_none() {
        let subject = Signatures(functionName: "bare(_:)", type: Self.self, file: #file, line: #line)

        XCTAssertEqual(subject, .bare)
    }

    func test_a_single_unnamed_argument_suffix_is_added_when_the_case_has_one() {
        let subject = Signatures(functionName: "withUnnamed", type: Self.self, file: #file, line: #line)

        XCTAssertEqual(subject, .withUnnamed)
    }

    func test_an_unknown_signature_traps() {
        XCTAssertThrowsAssertion {
            _ = Signatures(functionName: "missing()", type: Self.self, file: #file, line: #line)
        }

        XCTAssertThrowsAssertion {
            _ = Signatures(functionName: "plain(other:)", type: Self.self, file: #file, line: #line)
        }
    }

    func test_raw_values_round_trip() {
        XCTAssertEqual(Signatures.plain.rawValue, "plain()")
        XCTAssertEqual(Signatures(rawValue: "plain()"), .plain)
        XCTAssertNil(Signatures(rawValue: "nope"))
    }
}

private enum Signatures: String, StringRepresentable {
    case plain = "plain()"
    case withUnnamed = "withUnnamed(_:)"
    case bare
}
