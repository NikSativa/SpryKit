import Foundation
import SpryKit
import XCTest

final class XCTAssertEqualAnyTests: XCTestCase {
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
}
