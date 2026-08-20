import Foundation

internal extension String {
    func validateArguments(_ arguments: [Any?], on fakeType: (some Any).Type) {
        if arguments.isEmpty {
            return
        }

        if firstIndex(of: "(") == nil {
            return
        }

        let signatureCount = components(separatedBy: ":").count - 1
        if arguments.count != signatureCount {
            Constant.FatalError.wrongNumberOfArgsBeingStubbed(fakeType: fakeType, functionName: self, passedArguments: arguments, signatureCount: signatureCount)
        }
    }
}
