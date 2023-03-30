import Foundation
import XCTest

@inline(__always)
public func XCTAssertThrowsError(_ error: @autoclosure () -> Error,
                                 _ message: @autoclosure () -> String = "",
                                 file: StaticString = #file,
                                 line: UInt = #line,
                                 _ expression: () throws -> some Any) {
    XCTAssertThrowsError(try expression(), message(), file: file, line: line) { thrown in
        XCTAssertEqualError(thrown, error(), message(), file: file, line: line)
    }
}

@inline(__always)
public func XCTAssertThrowsError(_ expression: @autoclosure () throws -> some Any,
                                 _ error: @autoclosure () -> Error,
                                 _ message: @autoclosure () -> String = "",
                                 file: StaticString = #file,
                                 line: UInt = #line) {
    XCTAssertThrowsError(error(), message(), file: file, line: line, expression)
}

// MARK: - NotThrowsError

@inline(__always)
@discardableResult
public func XCTAssertNoThrowError<T>(_ message: @autoclosure () -> String = "",
                                     file: StaticString = #file,
                                     line: UInt = #line,
                                     _ expression: () throws -> T) -> T? {
    do {
        return try expression()
    } catch {
        XCTFail(message() + ". error: " + error.localizedDescription, file: file, line: line)
        return nil
    }
}

@inline(__always)
@discardableResult
public func XCTAssertNoThrowError<T>(_ expression: @autoclosure () throws -> T,
                                     _ message: @autoclosure () -> String = "",
                                     file: StaticString = #file,
                                     line: UInt = #line) -> T? {
    return XCTAssertNoThrowError(message(), file: file, line: line, expression)
}
