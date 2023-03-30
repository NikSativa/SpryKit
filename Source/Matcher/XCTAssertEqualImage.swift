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
        let lhs = try XCTUnwrap(try expression1(), message(), file: file, line: line)
        let rhs = try XCTUnwrap(try expression2(), message(), file: file, line: line)

        if condition {
            XCTAssertEqual(lhs.size.width, rhs.size.width, accuracy: 0.001)
            XCTAssertEqual(lhs.size.height, rhs.size.height, accuracy: 0.001)
            XCTAssertEqual(lhs, rhs, message(), file: file, line: line)

            #if os(iOS) || os(tvOS) || os(watchOS)
            XCTAssertEqual(lhs.pngData(), rhs.pngData(), message(), file: file, line: line)
            #elseif os(macOS)
            XCTAssertEqual(lhs.png, rhs.png, message(), file: file, line: line)
            #else
            #error("unsupported os")
            #endif
        } else {
            XCTAssertNotEqual(lhs.size.width, rhs.size.width, accuracy: 0.001)
            XCTAssertNotEqual(lhs.size.height, rhs.size.height, accuracy: 0.001)
            XCTAssertNotEqual(lhs, rhs, message(), file: file, line: line)

            #if os(iOS) || os(tvOS) || os(watchOS)
            XCTAssertNotEqual(lhs.pngData(), rhs.pngData(), message(), file: file, line: line)
            #elseif os(macOS)
            XCTAssertNotEqual(lhs.png, rhs.png, message(), file: file, line: line)
            #else
            #error("unsupported os")
            #endif
        }
    } catch {
        XCTFail(message() + ". " + error.localizedDescription, file: file, line: line)
    }
}

#if os(macOS)
private extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}

private extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

private extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}
#endif
