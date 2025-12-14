#if canImport(XCTest)
import Foundation
import XCTest

// MARK: - public

@inline(__always)
public func XCTAssertEqualImage(_ expression1: @autoclosure () throws -> Image?,
                                _ expression2: @autoclosure () throws -> Image?,
                                _ message: @autoclosure () -> String = "",
                                file: StaticString = #filePath,
                                line: UInt = #line) {
    AssertEqual(condition: true,
                expression1: expression1,
                expression2: expression2,
                message: message,
                file: file,
                line: line)
}

@inline(__always)
public func XCTAssertNotEqualImage(_ expression1: @autoclosure () throws -> Image?,
                                   _ expression2: @autoclosure () throws -> Image?,
                                   _ message: @autoclosure () -> String = "",
                                   file: StaticString = #filePath,
                                   line: UInt = #line) {
    AssertEqual(condition: false,
                expression1: expression1,
                expression2: expression2,
                message: message,
                file: file,
                line: line)
}

@inline(__always)
public func XCTAssertEqualImage(_ expression2: @autoclosure () throws -> Image?,
                                _ message: @autoclosure () -> String = "",
                                file: StaticString = #filePath,
                                line: UInt = #line,
                                _ expression1: () throws -> Image?) {
    AssertEqual(condition: true,
                expression1: expression1,
                expression2: expression2,
                message: message,
                file: file,
                line: line)
}

@inline(__always)
public func XCTAssertNotEqualImage(_ expression2: @autoclosure () throws -> Image?,
                                   _ message: @autoclosure () -> String = "",
                                   file: StaticString = #filePath,
                                   line: UInt = #line,
                                   _ expression1: () throws -> Image?) {
    AssertEqual(condition: false,
                expression1: expression1,
                expression2: expression2,
                message: message,
                file: file,
                line: line)
}

// MARK: - private

@inline(__always)
private func AssertEqual(condition: Bool,
                         expression1: () throws -> Image?,
                         expression2: () throws -> Image?,
                         message: () -> String,
                         file: StaticString,
                         line: UInt) {
    do {
        let lhs = try XCTUnwrap(expression1(), message(), file: file, line: line)
        let rhs = try XCTUnwrap(expression2(), message(), file: file, line: line)

        if condition {
            XCTAssertEqual(lhs.testData(), rhs.testData(), message(), file: file, line: line)
        } else {
            XCTAssertNotEqual(lhs.testData(), rhs.testData(), message(), file: file, line: line)
        }
    } catch {
        XCTFail(message() + ". " + error.localizedDescription, file: file, line: line)
    }
}

#endif // canImport(XCTest)
