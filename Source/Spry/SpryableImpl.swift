import Foundation

public extension Spryable {
    // MARK: - Instance

    func spryify<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        functionName.validateArguments(arguments, on: Self.self)

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
        functionName.validateArguments(arguments, on: Self.self)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        functionName.validateArguments(arguments, on: Self.self)

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
        functionName.validateArguments(arguments, on: Self.self)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    func spryifyAsync<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) async -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: Fallback<T>.noFallback)
        }
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try await stubbedValue.get().value(isCancellable: false)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func spryifyAsync<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) async -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        }
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try await stubbedValue.get().value(isCancellable: false)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func spryifyAsyncThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) async throws -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: Fallback<T>.noFallback)
        }
        internal_recordCall(function: function, arguments: arguments)
        return try await stubbedValue.get().value(isCancellable: true)
    }

    func spryifyAsyncThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) async throws -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        }
        internal_recordCall(function: function, arguments: arguments)
        return try await stubbedValue.get().value(isCancellable: true)
    }

    func resetCallsAndStubs() {
        resetCalls()
        resetStubs()
    }

    // MARK: - Static

    static func spryify<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        functionName.validateArguments(arguments, on: Self.self)

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
        functionName.validateArguments(arguments, on: Self.self)

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
        functionName.validateArguments(arguments, on: Self.self)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    static func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        defer {
            internal_recordCall(function: function, arguments: arguments)
        }
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    static func spryifyAsync<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) async -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: Fallback<T>.noFallback)
        }
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try await stubbedValue.get().value(isCancellable: false)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func spryifyAsync<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) async -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        }
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try await stubbedValue.get().value(isCancellable: false)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func spryifyAsyncThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) async throws -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: Fallback<T>.noFallback)
        }
        internal_recordCall(function: function, arguments: arguments)
        return try await stubbedValue.get().value(isCancellable: true)
    }

    static func spryifyAsyncThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) async throws -> T {
        functionName.validateArguments(arguments, on: Self.self)

        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        let stubbedValue = Result {
            return try internal_asyncStubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        }
        internal_recordCall(function: function, arguments: arguments)
        return try await stubbedValue.get().value(isCancellable: true)
    }

    static func resetCallsAndStubs() {
        resetCalls()
        resetStubs()
    }
}
