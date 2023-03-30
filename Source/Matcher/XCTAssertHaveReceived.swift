import Foundation
import XCTest

// MARK: - public

/// Matcher used to test whether or not a function or property has been called on an object.
///
/// ## Examples ##
/// ```swift
/// // only the first argument has to equate to the actual argument passed in.
/// XCTAssertHaveReceived(service, .loadJSON, with: URL("www.google.com")!, Argument.anything)
///
/// // both arguments have to equate to the actual arguments passed in.
/// XCTAssertHaveReceived(service, .loadJSON, with: URL("www.google.com")!, 5.0, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveReceived<T: Spyable>(_ spyable: T?,
                                              _ function: T.Function,
                                              with arguments: SpryEquatable?...,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              file: StaticString = #filePath,
                                              line: UInt = #line) {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

/// Matcher used to test whether or not a function or property has been called on an object.
///
/// ## Examples ##
/// ```swift
/// // any arguments will pass validation as long as the function was called.
/// XCTAssertHaveReceived(service, .loadJSON)
///
/// // will only pass if the function was exactly one time.
/// XCTAssertHaveReceived(service, .loadJSON, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveReceived<T: Spyable>(_ spyable: T?,
                                              _ function: T.Function,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              file: StaticString = #filePath,
                                              line: UInt = #line) {
    let arguments: [SpryEquatable?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

// MARK: - HaveNotReceived

/// Matcher used to test whether or not a function or property has not been called on an object.
///
/// ## Examples ##
/// ```swift
/// // only the first argument has to equate to the actual argument passed in.
/// XCTAssertHaveNotReceived(service, .loadJSON, with: URL("www.google.com")!, Argument.anything)
///
/// // both arguments have to equate to the actual arguments passed in.
/// XCTAssertHaveNotReceived(service, .loadJSON, with: URL("www.google.com")!, 5.0, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveNotReceived<T: Spyable>(_ spyable: T?,
                                                 _ function: T.Function,
                                                 with arguments: SpryEquatable?...,
                                                 countSpecifier: CountSpecifier = .atLeast(1),
                                                 file: StaticString = #filePath,
                                                 line: UInt = #line) {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(!result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

/// Matcher used to test whether or not a function or property has not been called on an object.
///
/// ## Examples ##
/// ```swift
/// // any arguments will pass validation as long as the function was called.
/// XCTAssertHaveNotReceived(service, .loadJSON)
///
/// // will only pass if the function was exactly one time.
/// XCTAssertHaveNotReceived(service, .loadJSON, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveNotReceived<T: Spyable>(_ spyable: T?,
                                                 _ function: T.Function,
                                                 countSpecifier: CountSpecifier = .atLeast(1),
                                                 file: StaticString = #filePath,
                                                 line: UInt = #line) {
    let arguments: [SpryEquatable?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(!result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

// MARK: - HaveReceived on a class

/// Matcher used to test whether or not a function or property has been called on a class.
///
/// ## Examples ##
/// ```swift
/// // only the first argument has to equate to the actual argument passed in.
/// XCTAssertHaveReceived(Service.self, .loadJSON, with: URL("www.google.com")!, Argument.anything)
///
/// // both arguments have to equate to the actual arguments passed in.
/// XCTAssertHaveReceived(Service.self, .loadJSON, with: URL("www.google.com")!, 5.0, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveReceived<T: Spyable>(_ spyable: T.Type?,
                                              _ function: T.ClassFunction,
                                              with arguments: SpryEquatable?...,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              file: StaticString = #filePath,
                                              line: UInt = #line) {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

/// Matcher used to test whether or not a function or property has been called on a class.
///
/// ## Examples ##
/// ```swift
/// // any arguments will pass validation as long as the function was called.
/// XCTAssertHaveReceived(Service.self, .loadJSON)
///
/// // will only pass if the function was exactly one time.
/// XCTAssertHaveReceived(Service.self, .loadJSON, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveReceived<T: Spyable>(_ spyable: T.Type?,
                                              _ function: T.ClassFunction,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              file: StaticString = #filePath,
                                              line: UInt = #line) {
    let arguments: [SpryEquatable?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

// MARK: - HaveNotReceived on a class

/// Matcher used to test whether or not a function or property has not been called on a class.
///
/// ## Examples ##
/// ```swift
/// // only the first argument has to equate to the actual argument passed in.
/// XCTAssertHaveNotReceived(Service.self, .loadJSON, with: URL("www.google.com")!, Argument.anything)
///
/// // both arguments have to equate to the actual arguments passed in.
/// XCTAssertHaveNotReceived(Service.self, .loadJSON, with: URL("www.google.com")!, 5.0, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveNotReceived<T: Spyable>(_ spyable: T.Type?,
                                                 _ function: T.ClassFunction,
                                                 with arguments: SpryEquatable?...,
                                                 countSpecifier: CountSpecifier = .atLeast(1),
                                                 file: StaticString = #filePath,
                                                 line: UInt = #line) {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(!result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

/// Matcher used to test whether or not a function or property has not been called on a class.
///
/// ## Examples ##
/// ```swift
/// // any arguments will pass validation as long as the function was called.
/// XCTAssertHaveNotReceived(Service.self, .loadJSON)
///
/// // will only pass if the function was exactly one time.
/// XCTAssertHaveNotReceived(Service.self, .loadJSON, countSpecifier: .exactly(1))
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@inline(__always)
public func XCTAssertHaveNotReceived<T: Spyable>(_ spyable: T.Type?,
                                                 _ function: T.ClassFunction,
                                                 countSpecifier: CountSpecifier = .atLeast(1),
                                                 file: StaticString = #filePath,
                                                 line: UInt = #line) {
    let arguments: [SpryEquatable?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        XCTFail(descriptionOfAttempted, file: file, line: line)
        return
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    XCTAssertTrue(!result.success, descriptionOfAttempted + " \(result.recordedCallsDescription)", file: file, line: line)
}

// MARK: - Private

private func descriptionOfExpectation(actualType: Any.Type, functionName: String, arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> String {
    var descriptionOfAttempt = "receive <\(functionName)> on <\(actualType)>"

    if !arguments.isEmpty {
        let argumentsDescription = arguments.map { element in
            if let element {
                return "<\(element)>"
            } else {
                return "<nil>"
            }
        }.joined(separator: ", ")
        descriptionOfAttempt += " with \(argumentsDescription)"
    }

    let countDescription: String
    let count: Int
    switch countSpecifier {
    case .exactly(let _count):
        countDescription = "exactly"
        count = _count
    case .atLeast(let _count) where _count != 1:
        countDescription = "at least"
        count = _count
    case .atMost(let _count):
        countDescription = "at most"
        count = _count
    default:
        countDescription = ""
        count = -1
    }

    if !countDescription.isEmpty {
        let pluralism = count == 1 ? "" : "s"
        descriptionOfAttempt += " \(countDescription) \(count) time\(pluralism)"
    }

    return descriptionOfAttempt
}

private func descriptionOfNilAttempt(arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> String {
    var descriptionOfAttempt = "receive function"

    if !arguments.isEmpty {
        descriptionOfAttempt += " with arguments"
    }

    switch countSpecifier {
    case .exactly:
        descriptionOfAttempt += " 'count' times"
    case .atLeast(let count) where count != 1:
        descriptionOfAttempt += " at least 'count' times"
    case .atMost:
        descriptionOfAttempt += " at most 'count' times"
    default:
        break
    }

    return descriptionOfAttempt
}
