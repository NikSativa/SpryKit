import Foundation
import XCTest

// MARK: - public

@inline(__always)
public func XCTAssertEqualError(_ lhs: @autoclosure () throws -> Error?,
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
public func XCTAssertNotEqualError(_ lhs: @autoclosure () throws -> Error?,
                                   _ rhs: @autoclosure () throws -> Error?,
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
                                _ lhs: () throws -> Error?) {
    AssertEqual(condition: true,
                lhs: lhs,
                rhs: rhs,
                message: message,
                file: file,
                line: line)
}

@inline(__always)
public func XCTAssertNotEqualError(_ rhs: @autoclosure () throws -> Error?,
                                   _ message: @autoclosure () -> String = "",
                                   file: StaticString = #filePath,
                                   line: UInt = #line,
                                   _ lhs: () throws -> Error?) {
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
                         lhs: () throws -> Error?,
                         rhs: () throws -> Error?,
                         message: () -> String,
                         file: StaticString,
                         line: UInt) {
    do {
        let lhs = try XCTUnwrap(try lhs(), message(), file: file, line: line)
        let rhs = try XCTUnwrap(try rhs(), message(), file: file, line: line)

        if condition {
            XCTAssertEqual(lhs as NSError, rhs as NSError, message(), file: file, line: line)
        } else {
            XCTAssertNotEqual(lhs as NSError, rhs as NSError, message(), file: file, line: line)
        }
    } catch {
        XCTFail(message() + ". " + error.localizedDescription, file: file, line: line)
    }
}
