import CwlPreconditionTesting
import Foundation
import XCTest

@inline(__always)
public func XCTAssertThrowsAssertion(_ expression: @autoclosure @escaping () throws -> some Any,
                                     _ message: @autoclosure () -> String = "",
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertNotNil(catchBadInstruction(in: {
        do {
            _ = try expression()
        } catch {
            XCTFail("catch error: " + error.localizedDescription, file: file, line: line)
        }
    }), message(), file: file, line: line)
}
