#if canImport(XCTest)
import Foundation
import XCTest

// MARK: - public

@inline(__always)
public func XCTAssertEqualError(_ lhs: @autoclosure () -> Error?,
                                _ rhs: @autoclosure () -> Error?,
                                _ message: @autoclosure () -> String = "",
                                file: StaticString = #filePath,
                                line: UInt = #line) {
    AssertEqual(condition: true,
                lhs: lhs,
                rhs: rhs,
                message: message,
                file: file,
                line: line)
}

@inline(__always)
public func XCTAssertNotEqualError(_ lhs: @autoclosure () -> Error?,
                                   _ rhs: @autoclosure () -> Error?,
                                   _ message: @autoclosure () -> String = "",
                                   file: StaticString = #filePath,
                                   line: UInt = #line) {
    AssertEqual(condition: false,
                lhs: lhs,
                rhs: rhs,
                message: message,
                file: file,
                line: line)
}

@inline(__always)
public func XCTAssertEqualError(_ rhs: @autoclosure () -> Error?,
                                _ message: @autoclosure () -> String = "",
                                file: StaticString = #filePath,
                                line: UInt = #line,
                                _ lhs: () -> Error?) {
    AssertEqual(condition: true,
                lhs: lhs,
                rhs: rhs,
                message: message,
                file: file,
                line: line)
}

@inline(__always)
public func XCTAssertNotEqualError(_ rhs: @autoclosure () -> Error?,
                                   _ message: @autoclosure () -> String = "",
                                   file: StaticString = #filePath,
                                   line: UInt = #line,
                                   _ lhs: () -> Error?) {
    AssertEqual(condition: false,
                lhs: lhs,
                rhs: rhs,
                message: message,
                file: file,
                line: line)
}

// MARK: - private

@inline(__always)
private func AssertEqual(condition: Bool,
                         lhs: () -> Error?,
                         rhs: () -> Error?,
                         message: () -> String,
                         file: StaticString,
                         line: UInt) {
    guard let rhs = rhs() else {
        XCTFail("expected error is nil, use `XCTAssertNil` instead. " + message(), file: file, line: line)
        return
    }
    guard let lhs = lhs() else {
        XCTFail("actual error is nil, use `XCTAssertNil` instead. " + message(), file: file, line: line)
        return
    }

    if condition {
        XCTAssertEqual(lhs as NSError, rhs as NSError, message(), file: file, line: line)
    } else {
        XCTAssertNotEqual(lhs as NSError, rhs as NSError, message(), file: file, line: line)
    }
}

#endif // canImport(XCTest)
