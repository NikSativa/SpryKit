import Foundation

/// A global NSMapTable to hold onto stubs for types conforming to Stubbable. This map table has "weak to strong objects" options.
///
/// - Important: Do NOT use this object.
#if swift(>=5.9)
private nonisolated(unsafe) var stubsMapTable: NSMapTable<AnyObject, SpryDictionary<StubInfo>> = NSMapTable.weakToStrongObjects()
#else
private var stubsMapTable: NSMapTable<AnyObject, SpryDictionary<StubInfo>> = NSMapTable.weakToStrongObjects()
#endif

/// Used to determine if a fallback was given in the event of that no stub is found.
internal enum Fallback<T> {
    case noFallback
    case fallback(T)
}

public extension Stubbable {
    // MARK: - Instance

    internal var _stubsDictionary: SpryDictionary<StubInfo> {
        guard let stubsDict = stubsMapTable.object(forKey: self) else {
            let stubDict = SpryDictionary<StubInfo>()
            stubsMapTable.setObject(stubDict, forKey: self)
            return stubDict
        }

        return stubsDict
    }

    func stub(_ function: Function) -> Stub {
        let stub = StubInfo(functionName: function.rawValue, stubCompleteHandler: { [weak self] stub in
            guard let welf = self else {
                return
            }

            handleDuplicates(stubsDictionary: welf._stubsDictionary, stub: stub, again: false)
        })
        _stubsDictionary.append(stub)

        return stub
    }

    func stubAgain(_ function: Function) -> Stub {
        let stub = StubInfo(functionName: function.rawValue, stubCompleteHandler: { [weak self] stub in
            guard let welf = self else {
                return
            }

            handleDuplicates(stubsDictionary: welf._stubsDictionary, stub: stub, again: true)
        })
        _stubsDictionary.append(stub)

        return stub
    }

    func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    func resetStubs() {
        _stubsDictionary.clearAll()
    }

    // MARK: - Static

    internal static var _stubsDictionary: SpryDictionary<StubInfo> {
        guard let stubDict = stubsMapTable.object(forKey: self) else {
            let stubDict = SpryDictionary<StubInfo>()
            stubsMapTable.setObject(stubDict, forKey: self)
            return stubDict
        }

        return stubDict
    }

    static func stub(_ function: ClassFunction) -> Stub {
        let stub = StubInfo(functionName: function.rawValue, stubCompleteHandler: { stub in
            handleDuplicates(stubsDictionary: _stubsDictionary, stub: stub, again: false)
        })
        _stubsDictionary.append(stub)

        return stub
    }

    static func stubAgain(_ function: ClassFunction) -> Stub {
        let stub = StubInfo(functionName: function.rawValue, stubCompleteHandler: { stub in
            handleDuplicates(stubsDictionary: _stubsDictionary, stub: stub, again: true)
        })
        _stubsDictionary.append(stub)

        return stub
    }

    static func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    static func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    static func resetStubs() {
        _stubsDictionary.clearAll()
    }

    internal func internal_stubbedValue<T>(_ function: Function, arguments: [Any?], fallback: Fallback<T>) throws -> T {
        let stubsForFunctionName = _stubsDictionary.get(for: function.rawValue)

        if stubsForFunctionName.isEmpty {
            return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect { $0.arguments.isEmpty }

        for stub in stubsWithArgs {
            if isEqualArgsLists(fakeType: Self.self, functionName: function.rawValue, specifiedArgs: stub.arguments, actualArgs: arguments) {
                let rawValue = try stub.returnValue(for: arguments)

                if isNil(rawValue) {
                    // nils won't cast to T even when T is Optional unless cast to Any first
                    if let castedValue = rawValue as Any as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                } else {
                    // values won't cast to T when T is a protocol if values is cast to Any first
                    if let castedValue = rawValue as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                }
            }
        }

        for stub in stubsWithoutArgs {
            let rawValue = try stub.returnValue(for: arguments)

            if isNil(rawValue) {
                // nils won't cast to T even when T is Optional unless cast to Any first
                if let castedValue = rawValue as Any as? T {
                    return castedValue
                }
            } else {
                // values won't cast to T when T is a protocol if values is cast to Any first
                if let castedValue = rawValue as? T {
                    return castedValue
                }
            }
        }

        return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
    }

    internal static func internal_stubbedValue<T>(_ function: ClassFunction, arguments: [Any?], fallback: Fallback<T>) throws -> T {
        let stubsForFunctionName = _stubsDictionary.get(for: function.rawValue)

        if stubsForFunctionName.isEmpty {
            return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect { $0.arguments.isEmpty }

        for stub in stubsWithArgs {
            if isEqualArgsLists(fakeType: Self.self, functionName: function.rawValue, specifiedArgs: stub.arguments, actualArgs: arguments) {
                let rawValue = try stub.returnValue(for: arguments)

                if isNil(rawValue) {
                    // nils won't cast to T even when T is Optional unless cast to Any first
                    if let castedValue = rawValue as Any as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                } else {
                    // values won't cast to T when T is a protocol if values is cast to Any first
                    if let castedValue = rawValue as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                }
            }
        }

        for stub in stubsWithoutArgs {
            let rawValue = try stub.returnValue(for: arguments)

            if isNil(rawValue) {
                // nils won't cast to T even when T is Optional unless cast to Any first
                if let castedValue = rawValue as Any as? T {
                    return castedValue
                }
            } else {
                // values won't cast to T when T is a protocol if values is cast to Any first
                if let castedValue = rawValue as? T {
                    return castedValue
                }
            }
        }

        return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
    }

    // MARK: - Private Helper Functions

    private func fatalErrorOrReturnFallback<T>(fallback: Fallback<T>, function: Function, arguments: [Any?]) -> T {
        switch fallback {
        case .noFallback:
            Constant.FatalError.noReturnValueFoundForInstanceFunction(stubbable: self, function: function, arguments: arguments, returnType: T.self)
        case .fallback(let value):
            return value
        }
    }

    private static func fatalErrorOrReturnFallback<T>(fallback: Fallback<T>, function: ClassFunction, arguments: [Any?]) -> T {
        switch fallback {
        case .noFallback:
            Constant.FatalError.noReturnValueFoundForClassFunction(stubbableType: self, function: function, arguments: arguments, returnType: T.self)
        case .fallback(let value):
            return value
        }
    }
}

private func handleDuplicates(stubsDictionary: SpryDictionary<StubInfo>, stub: StubInfo, again: Bool) {
    let duplicates = stubsDictionary.completedDuplicates(of: stub)

    if duplicates.isEmpty {
        return
    }

    if !stub.arguments.isEmpty {
        stub.functionName.validateArguments(stub.arguments)
    }

    if again {
        stubsDictionary.remove(stubs: duplicates, forFunctionName: stub.functionName)
    } else {
        Constant.FatalError.stubbingSameFunctionWithSameArguments(stub: stub)
    }
}

private func captureArguments(stub: StubInfo, actualArgs: [Any?]) {
    for (specifiedArg, actual) in zip(stub.arguments, actualArgs) {
        if let specifiedArg = specifiedArg as? ArgumentCaptor {
            specifiedArg.capture(actual)
        }
    }
}
