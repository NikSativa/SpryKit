import Foundation
import XCTest

@inline(__always)
public func XCTAssertEqualAny(_ lhs: @autoclosure () -> Any?,
                              _ rhs: @autoclosure () -> Any?,
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
public func XCTAssertNotEqualAny(_ lhs: @autoclosure () -> Any?,
                                 _ rhs: @autoclosure () -> Any?,
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

// MARK: - private

@inline(__always)
private func AssertEqual(condition: Bool,
                         lhs: () -> Any?,
                         rhs: () -> Any?,
                         message: () -> String,
                         file: StaticString,
                         line: UInt) {
    let result: Bool
    switch (lhs(), rhs()) {
    case (.none, .none):
        result = true
    case (.some(let lhs), .some(let rhs)):
        result = isAnyEqual(lhs, rhs)
    case (_, .none),
         (_, .some),
         (.none, _),
         (.some, _):
        result = false
    }

    if condition {
        XCTAssertTrue(result, message(), file: file, line: line)
    } else {
        XCTAssertFalse(result, message(), file: file, line: line)
    }
}
