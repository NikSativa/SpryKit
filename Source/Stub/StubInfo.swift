import Foundation

final class StubInfo {
    private enum StubType {
        case andReturn(Any?)
        case andDo(DoClosure<Any?>)
        case andDoVoid(DoClosure<Void>)
        case andThrow(Error)
    }

    let functionName: String

    var isComplete: Bool {
        return stubType != nil
    }

    private(set) var arguments: [Any?] = []
    var chronologicalIndex = -1

    private var stubType: StubType? {
        didSet {
            if stubType != nil {
                stubCompleteHandler?(self)
                stubCompleteHandler = nil
            }
        }
    }

    private var stubCompleteHandler: ((StubInfo) -> Void)?

    init(functionName: String,
         stubCompleteHandler: @escaping (StubInfo) -> Void) {
        self.functionName = functionName
        self.stubCompleteHandler = stubCompleteHandler
    }

    func returnValue(for args: [Any?]) throws -> Any? {
        guard let stubType else {
            Constant.FatalError.noReturnValueSourceFound(functionName: functionName)
        }

        switch stubType {
        case .andReturn(let value):
            return value
        case .andDo(let closure):
            return try closure(args)
        case .andDoVoid(let closure):
            return try closure(args)
        case .andThrow(let error):
            throw error
        }
    }
}

// MARK: - SpryItem

extension StubInfo: SpryItem {}

// MARK: - Stub

extension StubInfo: Stub {
    func with(_ arguments: Any...) -> Self {
        self.arguments += arguments
        return self
    }

    func andReturn() {
        stubType = .andReturn(())
    }

    func andReturn(_ value: Any?) {
        stubType = .andReturn(value)
    }

    func andDo(_ closure: @escaping DoClosure<Any?>) {
        stubType = .andDo(closure)
    }

    func andDoVoid(_ closure: @escaping DoClosure<Void>) {
        stubType = .andDoVoid(closure)
    }

    func andThrow(_ error: Error) {
        stubType = .andThrow(error)
    }
}

// MARK: - CustomStringConvertible

extension StubInfo: CustomStringConvertible {
    private func makeDescription() -> String {
        let argumentsDescription = arguments.map {
            return $0.map {
                "<\($0)>"
            } ?? "<nil>"
        }.joined(separator: ", ")
        let returnDescription = isNil(stubType) ? "nil" : "\(stubType!)"

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
        if arguments.isEmpty {
            return functionName
        }

        let arguementListStringRepresentation = makeFriendlyDescription(for: arguments, separator: ", ", closeEach: true)
        return functionName + " with " + arguementListStringRepresentation
    }
}
