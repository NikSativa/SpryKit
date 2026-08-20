#if canImport(XCTest) && canImport(CwlPreconditionTesting)
import CwlPreconditionTesting
import Foundation
import XCTest

/// Asserts that the expression traps (`fatalError`, `precondition`, `assert`).
///
/// - Important: Supported only on macOS, iOS and visionOS with `x86_64` or `arm64`.
///   On every other platform — tvOS and watchOS included — the assertion is skipped
///   and never fails, so a test relying on it silently turns green there.
///
/// - Warning: Simulator and Mac only. Catching a trap relies on Mach exception ports, which are
///   private API on a physical device, and a denied port aborts the whole test run instead of
///   failing a single test.
@inline(__always)
public func XCTAssertThrowsAssertion(_ message: @autoclosure () -> String = "",
                                     file: StaticString = #filePath,
                                     line: UInt = #line,
                                     _ expression: @escaping () throws -> some Any) {
    #if (os(macOS) || os(iOS) || os(visionOS)) && (arch(x86_64) || arch(arm64))
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
public func XCTAssertThrowsAssertion(expression: @autoclosure @escaping () throws -> some Any,
                                     _ message: @autoclosure () -> String = "",
                                     file: StaticString = #filePath,
                                     line: UInt = #line) {
    XCTAssertThrowsAssertion(message(), file: file, line: line, expression)
}

#endif // canImport(XCTest) && canImport(CwlPreconditionTesting)
