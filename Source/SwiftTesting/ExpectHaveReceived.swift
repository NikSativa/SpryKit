#if canImport(Testing)
import Foundation
import Testing

// MARK: - Helper Functions (shared with XCTest version)

private func descriptionOfExpectation(actualType: Any.Type, functionName: String, arguments: [Any?], countSpecifier: CountSpecifier) -> String {
    var descriptionOfAttempt = "receive <\(functionName)> on <\(actualType)>"

    if !arguments.isEmpty {
        let argumentsDescription = arguments.map { element in
            if let element {
                "<\(element)>"
            } else {
                "<nil>"
            }
        }
        .joined(separator: ", ")
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

private func descriptionOfNilAttempt(arguments: [Any?], countSpecifier: CountSpecifier) -> String {
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

// MARK: - public

/// Matcher used to test whether or not a function or property has been called on an object.
///
/// ## Examples ##
/// ```swift
/// @Test func testFetchUser() {
///     let fakeService = FakeUserService()
///     sut.loadUser()
///     expectHaveReceived(fakeService, .fetchUser, with: "1")
/// }
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@discardableResult
public func expectHaveReceived<T: Spyable>(_ spyable: T?,
                                           _ function: T.Function,
                                           with arguments: Any?...,
                                           countSpecifier: CountSpecifier = .atLeast(1),
                                           sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = result.success ? "" : "Expected to \(descriptionOfAttempted) but \(result.friendlyDescription)"
    #expect(result.success, "\(message)", sourceLocation: sourceLocation)
    return result.success
}

/// Matcher used to test whether or not a function or property has been called on an object.
///
/// ## Examples ##
/// ```swift
/// @Test func testServiceCall() {
///     let fakeService = FakeUserService()
///     sut.loadUser()
///     expectHaveReceived(fakeService, .loadJSON)
/// }
/// ```
///
/// - Parameter function: A string representation of the function signature
/// - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
@discardableResult
public func expectHaveReceived<T: Spyable>(_ spyable: T?,
                                           _ function: T.Function,
                                           countSpecifier: CountSpecifier = .atLeast(1),
                                           sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    let arguments: [Any?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = result.success ? "" : "Expected to \(descriptionOfAttempted) but \(result.friendlyDescription)"
    #expect(result.success, "\(message)", sourceLocation: sourceLocation)
    return result.success
}

// MARK: - HaveNotReceived

/// Matcher used to test whether or not a function or property has not been called on an object.
@discardableResult
public func expectHaveNotReceived<T: Spyable>(_ spyable: T?,
                                              _ function: T.Function,
                                              with arguments: Any?...,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to not \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = !result.success ? "" : "Expected to not \(descriptionOfAttempted) but it was called. \(result.friendlyDescription)"
    #expect(!result.success, "\(message)", sourceLocation: sourceLocation)
    return !result.success
}

/// Matcher used to test whether or not a function or property has not been called on an object.
@discardableResult
public func expectHaveNotReceived<T: Spyable>(_ spyable: T?,
                                              _ function: T.Function,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    let arguments: [Any?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to not \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = !result.success ? "" : "Expected to not \(descriptionOfAttempted) but it was called. \(result.friendlyDescription)"
    #expect(!result.success, "\(message)", sourceLocation: sourceLocation)
    return !result.success
}

// MARK: - HaveReceived on a class

/// Matcher used to test whether or not a function or property has been called on a class.
@discardableResult
public func expectHaveReceived<T: Spyable>(_ spyable: T.Type?,
                                           _ function: T.ClassFunction,
                                           with arguments: Any?...,
                                           countSpecifier: CountSpecifier = .atLeast(1),
                                           sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = result.success ? "" : "Expected to \(descriptionOfAttempted) but \(result.friendlyDescription)"
    #expect(result.success, "\(message)", sourceLocation: sourceLocation)
    return result.success
}

/// Matcher used to test whether or not a function or property has been called on a class.
@discardableResult
public func expectHaveReceived<T: Spyable>(_ spyable: T.Type?,
                                           _ function: T.ClassFunction,
                                           countSpecifier: CountSpecifier = .atLeast(1),
                                           sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    let arguments: [Any?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = result.success ? "" : "Expected to \(descriptionOfAttempted) but \(result.friendlyDescription)"
    #expect(result.success, "\(message)", sourceLocation: sourceLocation)
    return result.success
}

// MARK: - HaveNotReceived on a class

/// Matcher used to test whether or not a function or property has not been called on a class.
@discardableResult
public func expectHaveNotReceived<T: Spyable>(_ spyable: T.Type?,
                                              _ function: T.ClassFunction,
                                              with arguments: Any?...,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to not \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = !result.success ? "" : "Expected to not \(descriptionOfAttempted) but it was called. \(result.friendlyDescription)"
    #expect(!result.success, "\(message)", sourceLocation: sourceLocation)
    return !result.success
}

/// Matcher used to test whether or not a function or property has not been called on a class.
@discardableResult
public func expectHaveNotReceived<T: Spyable>(_ spyable: T.Type?,
                                              _ function: T.ClassFunction,
                                              countSpecifier: CountSpecifier = .atLeast(1),
                                              sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
    let arguments: [Any?] = []
    guard let spyable else {
        let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
        Issue.record("Expected to not \(descriptionOfAttempted) but spyable is nil", sourceLocation: sourceLocation)
        return false
    }

    let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
    let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)
    let message = !result.success ? "" : "Expected to not \(descriptionOfAttempted) but it was called. \(result.friendlyDescription)"
    #expect(!result.success, "\(message)", sourceLocation: sourceLocation)
    return !result.success
}

#endif // canImport(Testing)
