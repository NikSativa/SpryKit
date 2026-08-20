import Foundation
import SpryKit
import XCTest

final class XCTAssertThrowsErrorXCTests: XCTestCase {
    fileprivate enum Error: Swift.Error {
        case one
        case two
    }

    func test_errors() {
        XCTAssertThrowsError(try throwError(), Error.one)
        XCTAssertThrowsError(Error.one) {
            try throwError()
        }

        XCTAssertNoThrowError(try notThrowError())
        XCTAssertNoThrowError {
            try notThrowError()
        }
    }

    func test_no_throw_returns_the_value() throws {
        XCTAssertEqual(XCTAssertNoThrowError(try notThrowValue()), 7)
        XCTAssertEqual(XCTAssertNoThrowError { try notThrowValue() }, 7)
    }

    func test_an_unexpected_throw_is_reported() {
        var result: Int?
        XCTExpectFailure(failingBlock: {
            result = XCTAssertNoThrowError { try throwValue() }
        }, issueMatcher: { $0.compactDescription.contains("error:") })
        XCTAssertNil(result)

        XCTExpectFailure(failingBlock: {
            _ = XCTAssertNoThrowError("custom") { try throwValue() }
        }, issueMatcher: { $0.compactDescription.contains("custom") })
    }

    func test_a_missing_throw_is_reported() {
        XCTExpectFailure(failingBlock: {
            XCTAssertThrowsError(Error.one) { try notThrowError() }
        }, issueMatcher: { _ in true })
    }

    func test_a_different_error_is_reported() {
        XCTExpectFailure(failingBlock: {
            XCTAssertThrowsError(Error.two) { try throwError() }
        }, issueMatcher: { _ in true })
    }
}

private func notThrowValue() throws -> Int {
    return 7
}

private func throwValue() throws -> Int {
    throw XCTAssertThrowsErrorXCTests.Error.one
}

private func throwError() throws {
    throw XCTAssertThrowsErrorXCTests.Error.one
}

private func notThrowError() throws {
    // nothig
}
