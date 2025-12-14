#if canImport(Testing)
import Foundation
import Testing
@testable import SpryKit

@Suite("Argument Tests", .serialized)
struct ArgumentTests {
    @Test("CustomStringConvertible")
    func CustomStringConvertible() {
        #expect(Argument.anything.description == "Argument.anything", "Argument.anything")
        #expect(Argument.nonNil.description == "Argument.nonNil", "Argument.nonNil")
        #expect(Argument.nil.description == "Argument.nil", "Argument.nil")
        #expect(Argument.validator { _ in true }.description == "Argument.validator", "Argument.validator")
        #expect(Argument.closure.description == "Argument.closure", "Argument.closure")
        #expect(Argument.skipped.description == "Argument.skipped", "Argument.skipped")
    }

    @Test("Is equal args list")
    func is_equal_args_list() {
        var specifiedArgs: [Any?]!
        var actualArgs: [Any?]!

        let subjectAction: () -> Bool = {
            isEqualArgsLists(fakeType: Any.self, functionName: "", specifiedArgs: specifiedArgs, actualArgs: actualArgs)
        }

        // when the args lists have different counts
        specifiedArgs = []
        actualArgs = [1]
        expectThrowsAssertion {
            _ = subjectAction()
        }

        // .anything
        specifiedArgs = [
            Argument.anything,
            Argument.anything,
            Argument.anything
        ]
        actualArgs = [
            "asdf",
            3 as Int?,
            NSObject()
        ]
        #expect(subjectAction())

        // .skipped
        specifiedArgs = [
            Argument.anything,
            Argument.anything,
            Argument.skipped
        ]
        actualArgs = [
            "asdf",
            3 as Int?,
            Argument.anything
        ]
        #expect(subjectAction())

        specifiedArgs = [
            Argument.anything,
            Argument.anything,
            Argument.skipped
        ]
        actualArgs = [
            "asdf",
            3 as Int?,
            Argument.skipped
        ]
        #expect(subjectAction())

        // .nonNil
        specifiedArgs = [Argument.nonNil]
        actualArgs = [nil as String?]
        #expect(!subjectAction())

        specifiedArgs = [Argument.nonNil]
        actualArgs = [""]
        #expect(subjectAction())

        // .nil
        specifiedArgs = [
            Argument.nil,
            Argument.nil
        ]
        actualArgs = [
            nil as String?,
            nil as Int?
        ]
        #expect(subjectAction())

        specifiedArgs = [Argument.nil]
        actualArgs = ["" as String?]
        #expect(!subjectAction())

        // .validator
        var passedInArg: String!
        let actualArg = "actual arg"

        let customValidator = Argument.validator { actualArg -> Bool in
            passedInArg = actualArg as? String
            return true
        }
        specifiedArgs = [customValidator]
        actualArgs = [actualArg]

        #expect(subjectAction())
        #expect(passedInArg == actualArg)

        specifiedArgs = [Argument.validator { _ -> Bool in
            return true
        }]
        actualArgs = [""]
        #expect(subjectAction())

        specifiedArgs = [Argument.validator { _ -> Bool in
            return false
        }]
        actualArgs = [""]
        #expect(!subjectAction())

        // ArgumentCaptor
        specifiedArgs = [
            Argument.captor(),
            ArgumentCaptor()
        ]
        actualArgs = [
            "",
            ""
        ]
        #expect(subjectAction())

        specifiedArgs = [nil as Int?]
        actualArgs = [nil as String?]
        #expect(subjectAction())

        specifiedArgs = [nil as Int?]
        actualArgs = [""]
        #expect(!subjectAction())

        specifiedArgs = [""]
        actualArgs = [nil as Int?]
        #expect(!subjectAction())

        specifiedArgs = [""]
        actualArgs = [NotSpryEquatable()]
        #expect(!subjectAction())

        specifiedArgs = [SpryEquatableTestHelper(isEqual: true)]
        actualArgs = [SpryEquatableTestHelper(isEqual: false)]
        #expect(!subjectAction())

        specifiedArgs = [SpryEquatableTestHelper(isEqual: true)]
        actualArgs = [SpryEquatableTestHelper(isEqual: true)]
        #expect(subjectAction())

        specifiedArgs = [Argument.closure]
        actualArgs = [{}]
        #expect(subjectAction())

        // .skipped != .anything
        specifiedArgs = [
            Argument.anything,
            Argument.anything,
            Argument.anything
        ]
        actualArgs = [
            "asdf",
            3 as Int?,
            Argument.skipped
        ]
        #expect(!subjectAction())
    }
}
#endif // canImport(Testing)
