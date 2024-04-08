import Foundation
import SpryKit
import XCTest

final class XCTAssertEqualErrorTests: XCTestCase {
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
}
