import Foundation
import SpryKit
import XCTest

final class XCTAssertThrowsAssertionXCTests: XCTestCase {
    func test_assertion() {
        XCTAssertThrowsAssertion {
            throwAssertion()
        }

        XCTAssertThrowsAssertion {
            throwFatalError()
        }

        XCTAssertThrowsAssertion {
            throwPrecondition()
        }
    }

    func test_assertion_via_autoclosure() {
        XCTAssertThrowsAssertion(expression: throwFatalError())
        XCTAssertThrowsAssertion(expression: throwPrecondition(), "preconditionFailure must trap")
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
