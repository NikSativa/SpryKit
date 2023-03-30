import Foundation
import XCTest

/// Matcher used to determine if at least one call has been made.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
@inline(__always)
public func XCTAssertHaveRecordedCalls(_ spyable: some Spyable,
                                       file: StaticString = #filePath,
                                       line: UInt = #line) {
    XCTAssertTrue(!spyable._callsDictionary.calls.isEmpty,
                  descriptionOfActual(count: spyable._callsDictionary.calls.count),
                  file: file,
                  line: line)
}

/// Matcher used to determine if has not been made call.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
@inline(__always)
public func XCTAssertHaveNoRecordedCalls(_ spyable: some Spyable,
                                         file: StaticString = #filePath,
                                         line: UInt = #line) {
    XCTAssertTrue(spyable._callsDictionary.calls.isEmpty,
                  descriptionOfActual(count: spyable._callsDictionary.calls.count),
                  file: file,
                  line: line)
}

/// Matcher used to determine if at least one call has been made.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
@inline(__always)
public func XCTAssertHaveRecordedCalls(_ spyable: (some Spyable).Type,
                                       file: StaticString = #filePath,
                                       line: UInt = #line) {
    XCTAssertTrue(!spyable._callsDictionary.calls.isEmpty,
                  descriptionOfActual(count: spyable._callsDictionary.calls.count),
                  file: file,
                  line: line)
}

/// Matcher used to determine if has not been made call.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
@inline(__always)
public func XCTAssertHaveNoRecordedCalls(_ spyable: (some Spyable).Type,
                                         file: StaticString = #filePath,
                                         line: UInt = #line) {
    XCTAssertTrue(spyable._callsDictionary.calls.isEmpty,
                  descriptionOfActual(count: spyable._callsDictionary.calls.count),
                  file: file,
                  line: line)
}

// MARK: - Private Helpers

@inline(__always)
private func descriptionOfActual(count: Int) -> String {
    let pluralism = count == 1 ? "" : "s"
    return "have recorded \(count) call\(pluralism)"
}
