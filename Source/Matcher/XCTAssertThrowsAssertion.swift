import CwlPreconditionTesting
import Foundation
import XCTest

@inline(__always)
public func XCTAssertThrowsAssertion(_ message: @autoclosure () -> String = "",
                                     file: StaticString = #filePath,
                                     line: UInt = #line,
                                     _ expression: @escaping () throws -> some Any) {
    #if (os(macOS) || os(iOS) || supportsVisionOS) && (arch(x86_64) || arch(arm64))
    print(" --- ⚠️ ignore this assertion in console! this is a result of XCTAssertThrowsAssertion ⚠️ --- ")
    XCTAssertNotNil(catchBadInstruction(in: {
        do {
            _ = try expression()
        } catch {
            XCTFail("catch error: " + error.localizedDescription, file: file, line: line)
        }
    }), message(), file: file, line: line)
    #else
    print(" --- ⚠️ this is a result of XCTAssertThrowsAssertion. it is not supported on this platform ⚠️ --- ")
    #endif
}

@inline(__always)
public func XCTAssertThrowsAssertion(_ expression: @autoclosure @escaping () throws -> some Any,
                                     _ message: @autoclosure () -> String = "",
                                     file: StaticString = #filePath,
                                     line: UInt = #line) {
    XCTAssertThrowsAssertion(message(), file: file, line: line, expression)
}
