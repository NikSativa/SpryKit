#if (os(macOS) || os(iOS) || os(visionOS)) && (arch(x86_64) || arch(arm64))
import Foundation
import NSpry
import XCTest

final class XCTAssertThrowsAssertionTests: XCTestCase {
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
#endif
