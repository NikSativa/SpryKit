import Foundation
import Threading

final class StubInfo {
    private enum StubType {
        case andReturn(Any?)
        case andDo(DoClosure<Any?>)
        case andDoVoid(DoClosure<Void>)
        case andThrow(Error)
    }

    private struct State {
        var arguments: [Any?] = []
        var stubType: StubType?
        var chronologicalIndex: Int = -1
        var completeHandler: ((StubInfo) -> Void)?
    }

    let functionName: String

    private let state: AtomicValue<State>

    var isComplete: Bool {
        return state.syncUnchecked { state in
            return state.stubType != nil
        }
    }

    var arguments: [Any?] {
        return state.syncUnchecked { state in
            return state.arguments
        }
    }

    var chronologicalIndex: Int {
        get {
            return state.syncUnchecked { state in
                return state.chronologicalIndex
            }
        }
        set {
            state.syncUnchecked { state in
                state.chronologicalIndex = newValue
            }
        }
    }

    init(functionName: String,
         stubCompleteHandler: @escaping (StubInfo) -> Void) {
        self.functionName = functionName
        self.state = .init(wrappedValue: State(completeHandler: stubCompleteHandler))
    }

    func returnValue(for args: [Any?]) throws -> Any? {
        // The value is read out before reporting: a caught trap unwinds without running `defer`,
        // which would leave the stub locked forever.
        let stubType = state.syncUnchecked { state in
            return state.stubType
        }

        guard let stubType else {
            Constant.FatalError.noReturnValueSourceFound(functionName: functionName)
        }

        switch stubType {
        case let .andReturn(value):
            return value
        case let .andDo(closure):
            return try closure(args)
        case let .andDoVoid(closure):
            return try closure(args)
        case let .andThrow(error):
            throw error
        }
    }

    /// Records the outcome and hands the stub to its completion handler.
    ///
    /// The handler runs outside the lock: it walks the owning dictionary, which takes locks of its
    /// own.
    private func complete(with stubType: StubType) {
        let handler = state.syncUnchecked { state -> ((StubInfo) -> Void)? in
            state.stubType = stubType
            let handler = state.completeHandler
            state.completeHandler = nil
            return handler
        }

        handler?(self)
    }
}

// MARK: - SpryItem

extension StubInfo: SpryItem {}

// MARK: - Stub

extension StubInfo: Stub {
    func with(_ arguments: Any...) -> Self {
        state.syncUnchecked { state in
            state.arguments += arguments
        }

        return self
    }

    func andReturn() {
        complete(with: .andReturn(()))
    }

    func andReturn(_ value: Any?) {
        complete(with: .andReturn(value))
    }

    func andDo(_ closure: @escaping DoClosure<Any?>) {
        complete(with: .andDo(closure))
    }

    func andDoVoid(_ closure: @escaping DoClosure<Void>) {
        complete(with: .andDoVoid(closure))
    }

    func andThrow(_ error: Error) {
        complete(with: .andThrow(error))
    }
}

// MARK: - CustomStringConvertible

extension StubInfo: CustomStringConvertible {
    private func makeDescription() -> String {
        let (arguments, stubType) = state.syncUnchecked { state in
            return (state.arguments, state.stubType)
        }

        let argumentsDescription = arguments.map {
            return $0.map {
                "<\($0)>"
            } ?? "<nil>"
        }
        .joined(separator: ", ")
        let returnDescription = stubType.map { "\($0)" } ?? "nil"

        return "Stub(function: <\(functionName)>, args: <\(argumentsDescription)>, returnValue: <\(returnDescription)>)"
    }

    var description: String {
        return makeDescription()
    }
}

// MARK: - CustomDebugStringConvertible

extension StubInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        return makeDescription()
    }
}

// MARK: - SpryFriendlyStringConvertible

extension StubInfo: SpryFriendlyStringConvertible {
    var friendlyDescription: String {
        let arguments = arguments
        if arguments.isEmpty {
            return functionName
        }

        let argumentListStringRepresentation = makeFriendlyDescription(for: arguments, separator: ", ", closeEach: true)
        return functionName + " with " + argumentListStringRepresentation
    }
}
