import Foundation
import XCTest

@testable import NSpry

final class SpryEquatableTests: XCTestCase {
    func test_NOT_Equatable_and_AnyObject() {
        let myObject1 = AnyObjectOnly(p: 1)
        let myObject2 = AnyObjectOnly(p: 2)

        XCTAssertTrue(isAnyEqual(myObject1, myObject1))
        XCTAssertFalse(isAnyEqual(myObject1, myObject2))
    }

    func test_Equatable_and_AnyObject() {
        let myObject1 = AnyObjectAndEquatable()
        let myObject2 = AnyObjectAndEquatable()

        XCTAssertTrue(isAnyEqual(myObject1, myObject1))
        XCTAssertTrue(isAnyEqual(myObject1, myObject2))
    }

    func test_array_Element_conforms_to_SpryEquatable() {
        let baseArray = [1, 2, 3]

        XCTAssertTrue(isAnyEqual(baseArray, [1, 2, 3]))

        XCTAssertFalse(isAnyEqual(baseArray, [1, 2, 1]))
        XCTAssertFalse(isAnyEqual(baseArray, [1, 3, 2]))
        XCTAssertFalse(isAnyEqual(baseArray, [1, 2, 3, 4]))
        XCTAssertFalse(isAnyEqual(baseArray, [1, 2]))
    }

    func test_dictionary_Value_conforms_to_SpryEquatable() {
        let baseDict = [
            "1": 1,
            "2": 2
        ]

        XCTAssertTrue(isAnyEqual(baseDict, ["1": 1, "2": 2]))
        XCTAssertTrue(isAnyEqual(baseDict, ["2": 2, "1": 1]))

        XCTAssertFalse(isAnyEqual(baseDict, ["1": 5, "2": 5]))
        XCTAssertFalse(isAnyEqual(baseDict, ["1": 1, "2": 2, "3": 3]))
        XCTAssertFalse(isAnyEqual(baseDict, ["1": 1]))

        XCTAssertFalse(isAnyEqual(baseDict, [1: 1, 2: 2]))
        XCTAssertFalse(isAnyEqual(baseDict, [1: 1, 2: 2]))
    }

    func test_set_Value_conforms_to_SpryEquatable() {
        let baseDict: Set<String> = [
            "1",
            "2"
        ]

        XCTAssertTrue(isAnyEqual(baseDict, Set(["1", "2"])))
        XCTAssertTrue(isAnyEqual(baseDict, Set(["2", "1"])))

        XCTAssertFalse(isAnyEqual(baseDict, Set([1, 2])))
        XCTAssertFalse(isAnyEqual(baseDict, Set([2, 1])))
    }

    func test_optional() {
        var a: Int?
        var b: Int?
        var c: Int = 2
        let d: String? = nil
        let e: String = "e"

        XCTAssertTrue(isAnyEqual(a, b))
        a = 0
        XCTAssertFalse(isAnyEqual(a, b))
        b = 1
        XCTAssertFalse(isAnyEqual(a, b))
        b = 2
        XCTAssertFalse(isAnyEqual(a, b))
        a = 2
        XCTAssertTrue(isAnyEqual(a, b))

        XCTAssertTrue(isAnyEqual(a, c))
        XCTAssertTrue(isAnyEqual(c, b))

        c = 0
        XCTAssertFalse(isAnyEqual(a, c))
        XCTAssertFalse(isAnyEqual(c, b))

        XCTAssertFalse(isAnyEqual(c, d))
        XCTAssertFalse(isAnyEqual(d, c))
        XCTAssertFalse(isAnyEqual(a, d))
        XCTAssertFalse(isAnyEqual(d, a))

        XCTAssertFalse(isAnyEqual(c, e))
        XCTAssertFalse(isAnyEqual(e, c))
        XCTAssertFalse(isAnyEqual(a, e))
        XCTAssertFalse(isAnyEqual(e, a))
    }
}
