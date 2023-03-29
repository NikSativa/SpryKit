import Foundation
import XCTest

@inline(__always)
public func XCTAssertEqualError(_ lhs: Error?,
                                _ rhs: @autoclosure () -> Error,
                                _ message: @autoclosure () -> String = "",
                                file: StaticString = #filePath,
                                line: UInt = #line) {
    do {
        let lhs = try XCTUnwrap(lhs, message(), file: file, line: line)
        XCTAssertEqual(lhs as NSError, rhs() as NSError, message(), file: file, line: line)
    } catch {
        XCTFail(message(), file: file, line: line)
    }
}

@inline(__always)
public func XCTAssertNotEqualError(_ lhs: Error?,
                                   _ rhs: @autoclosure () -> Error,
                                   _ message: @autoclosure () -> String = "",
                                   file: StaticString = #filePath,
                                   line: UInt = #line) {
    do {
        let lhs = try XCTUnwrap(lhs, message(), file: file, line: line)
        XCTAssertNotEqual(lhs as NSError, rhs() as NSError, message(), file: file, line: line)
    } catch {
        XCTFail(message(), file: file, line: line)
    }
}
