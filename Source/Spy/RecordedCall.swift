import Foundation

final class RecordedCall {
    let functionName: String
    let arguments: [Any?]
    var chronologicalIndex = -1

    init(functionName: String, arguments: [Any?]) {
        self.functionName = functionName
        self.arguments = arguments
    }
}

// MARK: - CustomStringConvertible

extension RecordedCall: CustomStringConvertible {
    private func makeDescription() -> String {
        let argumentsString = arguments.map { "<\($0 as Any)>" }.joined(separator: ", ")
        return "RecordedCall(function: <\(functionName)>, arguments: <\(argumentsString)>)"
    }

    var description: String {
        return makeDescription()
    }
}

// MARK: - CustomDebugStringConvertible

extension RecordedCall: CustomDebugStringConvertible {
    var debugDescription: String {
        return makeDescription()
    }
}

// MARK: - SpryFriendlyStringConvertible

extension RecordedCall: SpryFriendlyStringConvertible {
    var friendlyDescription: String {
        if arguments.isEmpty {
            return functionName
        }

        let arguementListStringRepresentation = makeFriendlyDescription(for: arguments, separator: ", ", closeEach: true)
        return functionName + " with " + arguementListStringRepresentation
    }
}

// MARK: - SpryItem

extension RecordedCall: SpryItem {
    var isComplete: Bool {
        return true
    }
}
