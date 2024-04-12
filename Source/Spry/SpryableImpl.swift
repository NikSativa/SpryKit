import Foundation

public extension Spryable {
    // MARK: - Instance

    func spryify<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        functionName.validateArguments(arguments)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        do {
            defer {
                internal_recordCall(function: function, arguments: arguments)
            }
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        functionName.validateArguments(arguments)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        functionName.validateArguments(arguments)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        do {
            defer {
                internal_recordCall(function: function, arguments: arguments)
            }
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        functionName.validateArguments(arguments)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    func resetCallsAndStubs() {
        resetCalls()
        resetStubs()
    }

    // MARK: - Static

    static func spryify<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        functionName.validateArguments(arguments)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        do {
            defer {
                internal_recordCall(function: function, arguments: arguments)
            }
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func spryify<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        functionName.validateArguments(arguments)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        do {
            defer {
                internal_recordCall(function: function, arguments: arguments)
            }
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        functionName.validateArguments(arguments)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    static func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        functionName.validateArguments(arguments)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    static func resetCallsAndStubs() {
        resetCalls()
        resetStubs()
    }
}
