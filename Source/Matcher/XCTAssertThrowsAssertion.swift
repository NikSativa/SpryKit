#if (os(macOS) || os(iOS) || os(visionOS)) && (arch(x86_64) || arch(arm64))
import CwlPreconditionTesting
import Foundation
import XCTest

@inline(__always)
public func XCTAssertThrowsAssertion(_ message: @autoclosure () -> String = "",
                                     file: StaticString = #file,
                                     line: UInt = #line,
                                     _ expression: @escaping () throws -> some Any) {
    XCTAssertNotNil(catchBadInstruction(in: {
        do {
            _ = try expression()
        } catch {
            XCTFail("catch error: " + error.localizedDescription, file: file, line: line)
        }
    }), message(), file: file, line: line)
}

@inline(__always)
public func XCTAssertThrowsAssertion(_ expression: @autoclosure @escaping () throws -> some Any,
                                     _ message: @autoclosure () -> String = "",
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertThrowsAssertion(message(), file: file, line: line, expression)
}
#endif
