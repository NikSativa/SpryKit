import Foundation

enum AsyncStubbedValue<T> {
    case ready(T)
    case waiting(StubResponder, callID: Int, functionName: String)

    func value(isCancellable: Bool) async throws -> T {
        switch self {
        case let .ready(value):
            return value
        case let .waiting(responder, callID, functionName):
            let response = try await responder.response(toCall: callID, isCancellable: isCancellable)
            guard let value: T = castedStubValue(response) else {
                Constant.FatalError.responseOfWrongType(functionName: functionName, response: response, returnType: T.self)
            }

            return value
        }
    }
}
