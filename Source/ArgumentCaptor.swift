import Foundation
import Threading

/// Used to capture an argument for more detailed testing on an argument.
@preconcurrency
public final class ArgumentCaptor: @unchecked Sendable {
    @AtomicValue
    private var capturedArguments: [Any?] = []

    public init() {}

    /// Get an argument that was captured.
    ///
    /// - Parameter at: The index of the captured argument. The index cooresponds the number of times the specified function was called (when argument specifiers passed validation). For instance if the function was called 5 times and you want the argument captured during the 2nd call then ask for index 1, `getValue(at: 1)`. Defaults to 0. Asking for the an index that is out of bounds will result in a `fatalError()`.
    /// - Parameter as: The expected type of the argument captured. Asking for the wrong type will result in a `fatalError()`
    ///
    /// - Returns: The captured argument or fatal error if there was an issue.
    public func getValue<T>(at index: Int = 0, as _: T.Type = T.self) -> T {
        return $capturedArguments.syncUnchecked { capturedArguments in
            guard index >= 0, capturedArguments.count > index else {
                Constant.FatalError.capturedArgumentsOutOfBounds(index: index, capturedArguments: capturedArguments)
            }

            let capturedAsUnknownType = capturedArguments[index]
            guard let captured = capturedAsUnknownType as? T else {
                Constant.FatalError.argumentCaptorCouldNotReturnSpecifiedType(value: capturedAsUnknownType, type: T.self)
            }

            return captured
        }
    }

    public subscript<T>(_ index: Int) -> T {
        return getValue(at: index)
    }

    public func isType<T>(_: T.Type, at index: Int = 0) -> Bool {
        return $capturedArguments.syncUnchecked { capturedArguments in
            guard index >= 0, capturedArguments.count > index else {
                return false
            }

            return capturedArguments[index] is T
        }
    }

    internal func capture(_ argument: Any?) {
        $capturedArguments.syncUnchecked { capturedArguments in
            capturedArguments.append(argument)
        }
    }
}
