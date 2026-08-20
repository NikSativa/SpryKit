import Foundation
import XCTest
@testable import SpryKit

final class ArgumentXCTests: XCTestCase {
    func test_CustomStringConvertible() {
        XCTAssertEqual(Argument.anything.description, "Argument.anything", "Argument.anything")
        XCTAssertEqual(Argument.nonNil.description, "Argument.nonNil", "Argument.nonNil")
        XCTAssertEqual(Argument.nil.description, "Argument.nil", "Argument.nil")
        XCTAssertEqual(Argument.validator { _ in true }.description, "Argument.validator", "Argument.validator")
        XCTAssertEqual(Argument.closure.description, "Argument.closure", "Argument.closure")
        XCTAssertEqual(Argument.skipped.description, "Argument.skipped", "Argument.skipped")
    }

    func test_equatable() {
        XCTAssertEqual(Argument.anything, Argument.anything)
        XCTAssertEqual(Argument.skipped, Argument.skipped)
        XCTAssertEqual(Argument.nil, Argument.nil)
        XCTAssertEqual(Argument.nonNil, Argument.nonNil)
        XCTAssertEqual(Argument.closure, Argument.closure)
        XCTAssertNotEqual(Argument.anything, Argument.skipped)
        XCTAssertNotEqual(Argument.skipped, Argument.anything)
        XCTAssertNotEqual(Argument.nil, Argument.nonNil)
    }

    func test_isType() {
        XCTAssertTrue(matches(.isType(ArgumentBase.self), ArgumentBase.self))
        XCTAssertTrue(matches(.isType(ArgumentBase.self), ArgumentSub.self))
        XCTAssertFalse(matches(.isType(ArgumentBase.self), ArgumentBase()))
        XCTAssertFalse(matches(.isType(ArgumentBase.self), String.self))
        XCTAssertFalse(matches(.isType(ArgumentProtocol.self), ArgumentImpl.self))
    }

    func test_instanceOf() {
        XCTAssertTrue(matches(.instanceOf(ArgumentBase.self), ArgumentBase()))
        XCTAssertTrue(matches(.instanceOf(ArgumentBase.self), ArgumentSub()))
        XCTAssertTrue(matches(.instanceOf(ArgumentProtocol.self), ArgumentImpl()))
        XCTAssertFalse(matches(.instanceOf(ArgumentBase.self), ArgumentBase.self))
        XCTAssertFalse(matches(.instanceOf(ArgumentBase.self), 5))
    }

    private func matches(_ specified: Argument, _ actual: Any?) -> Bool {
        return isEqualArgsLists(specifiedArgs: [specified], actualArgs: [actual])
    }

    func test_is_equal_args_list() {
        var specifiedArgs: [Any?]!
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
        XCTAssertFalse(subjectAction())

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
        XCTAssertFalse(subjectAction())

        specifiedArgs = [SpryEquatableTestHelper(isEqual: true)]
        actualArgs = [SpryEquatableTestHelper(isEqual: false)]
        XCTAssertFalse(subjectAction())

        specifiedArgs = [SpryEquatableTestHelper(isEqual: true)]
        actualArgs = [SpryEquatableTestHelper(isEqual: true)]
        XCTAssertTrue(subjectAction())

        specifiedArgs = [Argument.closure]
        actualArgs = [{}]
        XCTAssertTrue(subjectAction())

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
        XCTAssertFalse(subjectAction())
    }
}

private class ArgumentBase {}
private final class ArgumentSub: ArgumentBase {}
private protocol ArgumentProtocol {}
private final class ArgumentImpl: ArgumentProtocol {}
