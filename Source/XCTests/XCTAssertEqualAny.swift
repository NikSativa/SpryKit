#if canImport(XCTest)
import Foundation
import XCTest

@inline(__always)
public func XCTAssertEqualAny(_ lhs: @autoclosure () -> Any?,
                              _ rhs: @autoclosure () -> Any?,
                              _ message: @autoclosure () -> String? = nil,
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
                                 _ message: @autoclosure () -> String? = nil,
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
                         message: () -> String?,
                         file: StaticString,
                         line: UInt) {
    let lhs = lhs()
    let rhs = rhs()
    let result: Bool =
        switch (lhs, rhs) {
        case (.none, .none):
            true
        case (.some(let lhs), .some(let rhs)):
            isAnyEqual(lhs, rhs)
        case (_, .none),
             (_, .some),
             (.none, _),
             (.some, _):
            false
        }

    if condition {
        XCTAssertTrue(result, message() ?? "\(describe(lhs)) is not equal to \(describe(rhs))\ndiff:\n\(Spry.diffMirror(lhs, rhs))", file: file, line: line)
    } else {
        XCTAssertFalse(result, message() ?? "\(describe(lhs)) is equal to \(describe(rhs))\ndiff:\n\(Spry.diffMirror(lhs, rhs))", file: file, line: line)
    }
}

#endif // canImport(XCTest)
