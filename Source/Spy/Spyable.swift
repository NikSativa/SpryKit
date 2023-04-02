import Foundation

/// A global NSMapTable to hold onto calls for types conforming to Spyable. This map table has "weak to strong objects" options.
///
/// - Important: Do NOT use this object.
private var callsMapTable: NSMapTable<AnyObject, SpryDictionary<RecordedCall>> = NSMapTable.weakToStrongObjects()

public extension Spyable {
    // MARK: Instance

    internal var _callsDictionary: SpryDictionary<RecordedCall> {
        guard let callsDict = callsMapTable.object(forKey: self) else {
            let callsDict = SpryDictionary<RecordedCall>()
            callsMapTable.setObject(callsDict, forKey: self)
            return callsDict
        }

        return callsDict
    }

    func recordCall(functionName: String = #function, arguments: Any?..., file: String = #file, line: Int = #line) {
        functionName.validateArguments(arguments)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
    }

    func didCall(_ function: Function, withArguments arguments: [SpryEquatable?] = [], countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
        function.rawValue.validateArguments(arguments)

        let success: Bool
        switch countSpecifier {
        case .exactly(let count):
            success = timesCalled(function, arguments: arguments) == count
        case .atLeast(let count):
            success = timesCalled(function, arguments: arguments) >= count
        case .atMost(let count):
            success = timesCalled(function, arguments: arguments) <= count
        }

        let _callsDictionary = _callsDictionary
        return DidCallResult(success: success,
                             description: _callsDictionary.description,
                             debugDescription: _callsDictionary.debugDescription,
                             friendlyDescription: _callsDictionary.friendlyDescription)
    }

    func resetCalls() {
        _callsDictionary.clearAll()
    }

    // MARK: Static

    internal static var _callsDictionary: SpryDictionary<RecordedCall> {
        guard let callsDict = callsMapTable.object(forKey: self) else {
            let callsDict = SpryDictionary<RecordedCall>()
            callsMapTable.setObject(callsDict, forKey: self)
            return callsDict
        }

        return callsDict
    }

    static func recordCall(functionName: String = #function, arguments: Any?..., file: String = #file, line: Int = #line) {
        functionName.validateArguments(arguments)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
    }

    static func didCall(_ function: ClassFunction, withArguments arguments: [SpryEquatable?] = [], countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
        function.rawValue.validateArguments(arguments)

        let success: Bool
        switch countSpecifier {
        case .exactly(let count):
            success = timesCalled(function, arguments: arguments) == count
        case .atLeast(let count):
            success = timesCalled(function, arguments: arguments) >= count
        case .atMost(let count):
            success = timesCalled(function, arguments: arguments) <= count
        }

        let _callsDictionary = _callsDictionary
        return DidCallResult(success: success,
                             description: _callsDictionary.description,
                             debugDescription: _callsDictionary.debugDescription,
                             friendlyDescription: _callsDictionary.friendlyDescription)
    }

    static func resetCalls() {
        _callsDictionary.clearAll()
    }

    // MARK: - Internal Functions

    /// This is for `Spryable` to act as a pass-through to record a call.
    internal func internal_recordCall(function: Function, arguments: [Any?]) {
        let call = RecordedCall(functionName: function.rawValue, arguments: arguments)
        _callsDictionary.append(call)
    }

    /// This is for `Spryable` to act as a pass-through to record a call.
    internal static func internal_recordCall(function: ClassFunction, arguments: [Any?]) {
        let call = RecordedCall(functionName: function.rawValue, arguments: arguments)
        _callsDictionary.append(call)
    }

    // MARK: - Private Functions

    private func timesCalled(_ function: Function, arguments: [SpryEquatable?]) -> Int {
        return numberOfMatchingCalls(fakeType: Self.self, functionName: function.rawValue, arguments: arguments, callsDictionary: _callsDictionary)
    }

    private static func timesCalled(_ function: ClassFunction, arguments: [SpryEquatable?]) -> Int {
        return numberOfMatchingCalls(fakeType: Self.self, functionName: function.rawValue, arguments: arguments, callsDictionary: _callsDictionary)
    }
}

// MARK: Private Functions

private func numberOfMatchingCalls(fakeType: (some Any).Type, functionName: String, arguments: [SpryEquatable?], callsDictionary: SpryDictionary<RecordedCall>) -> Int {
    let matchingFunctions = callsDictionary.get(for: functionName)

    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    if arguments.isEmpty {
        return matchingFunctions.count
    }

    return matchingFunctions.reduce(0) {
        return $0 + isEqualArgsLists(fakeType: fakeType, functionName: functionName, specifiedArgs: arguments, actualArgs: $1.arguments).toInt()
    }
}

private extension Bool {
    func toInt() -> Int {
        return self ? 1 : 0
    }
}
