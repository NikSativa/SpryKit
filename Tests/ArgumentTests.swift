import Foundation
import XCTest

@testable import NSpry

final class ArgumentTests: XCTestCase {
    func test_CustomStringConvertible() {
        XCTAssertEqual(Argument.anything.description, "Argument.anything")
        XCTAssertEqual(Argument.nonNil.description, "Argument.nonNil")
        XCTAssertEqual(Argument.nil.description, "Argument.nil")
        XCTAssertEqual(Argument.validator { _ in true }.description, "Argument.validator")
    }

    func test_is_equal_args_list() {
        var specifiedArgs: [SpryEquatable?]!
        var actualArgs: [Any?]!

        let subjectAction: () -> Bool = {
            return isEqualArgsLists(fakeType: Any.self, functionName: "", specifiedArgs: specifiedArgs, actualArgs: actualArgs)
        }

        // when the args lists have different counts
        specifiedArgs = []
        actualArgs = [1]
        XCTAssertThrowsAssertion {
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
        XCTAssertTrue(subjectAction())

        // .nonNil
        specifiedArgs = [Argument.nonNil]
        actualArgs = [nil as String?]
        XCTAssertFalse(subjectAction())

        specifiedArgs = [Argument.nonNil]
        actualArgs = [""]
        XCTAssertTrue(subjectAction())

        // .nil
        specifiedArgs = [
            Argument.nil,
            Argument.nil
        ]
        actualArgs = [
            nil as String?,
            nil as Int?
        ]
        XCTAssertTrue(subjectAction())

        specifiedArgs = [Argument.nil]
        actualArgs = ["" as String?]
        XCTAssertFalse(subjectAction())

        // .validator
        var passedInArg: String!
        let actualArg = "actual arg"

        let customValidator = Argument.validator { actualArg -> Bool in
            passedInArg = actualArg as? String
            return true
        }
        specifiedArgs = [customValidator]
        actualArgs = [actualArg]

        XCTAssertTrue(subjectAction())
        XCTAssertEqual(passedInArg, actualArg)

        specifiedArgs = [Argument.validator { _ -> Bool in
            return true
        }]
        actualArgs = [""]
        XCTAssertTrue(subjectAction())

        specifiedArgs = [Argument.validator { _ -> Bool in
            return false
        }]
        actualArgs = [""]
        XCTAssertFalse(subjectAction())

        // ArgumentCaptor
        specifiedArgs = [
            Argument.captor(),
            ArgumentCaptor()
        ]
        actualArgs = [
            "",
            ""
        ]
        XCTAssertTrue(subjectAction())

        specifiedArgs = [nil as Int?]
        actualArgs = [nil as String?]
        XCTAssertTrue(subjectAction())

        specifiedArgs = [nil as Int?]
        actualArgs = [""]
        XCTAssertFalse(subjectAction())

        specifiedArgs = [""]
        actualArgs = [nil as Int?]
        XCTAssertFalse(subjectAction())

        specifiedArgs = [""]
        actualArgs = [NotSpryEquatable()]
        XCTAssertThrowsAssertion {
            _ = subjectAction()
        }

        specifiedArgs = [SpryEquatableTestHelper(isEqual: false)]
        actualArgs = [SpryEquatableTestHelper(isEqual: false)]
        XCTAssertFalse(subjectAction())

        specifiedArgs = [SpryEquatableTestHelper(isEqual: true)]
        actualArgs = [SpryEquatableTestHelper(isEqual: true)]
        XCTAssertTrue(subjectAction())
    }
}
