import Foundation

internal extension String {
    func validateArguments(_ arguments: [Any?]) {
        if arguments.isEmpty {
            return
        }

        if firstIndex(of: "(") == nil {
            return
        }

        let actualCount = components(separatedBy: ":").count - 1
        if arguments.count != actualCount {
            Constant.FatalError.wrongNumberOfArgsBeingStubbed(fakeType: Self.self, functionName: self, specifiedArguments: arguments, actualCount: actualCount)
        }
    }
}
