import Foundation
import XCTest

@testable import NSpry

final class SpryEquatableTests: XCTestCase {
    func test_NOT_Equatable_and_AnyObject() {
        let myObject1 = AnyObjectOnly(p: 1)
        let myObject2 = AnyObjectOnly(p: 2)

        XCTAssertTrue(myObject1._isEqual(to: myObject1))
        XCTAssertFalse(myObject1._isEqual(to: myObject2))
    }

    func test_Equatable_and_AnyObject() {
        let myObject1 = AnyObjectAndEquatable()
        let myObject2 = AnyObjectAndEquatable()

        XCTAssertTrue(myObject1._isEqual(to: myObject1))
        XCTAssertTrue(myObject1._isEqual(to: myObject2))
    }

    func test_array_Element_conforms_to_SpryEquatable() {
        let baseArray = [1, 2, 3]

        XCTAssertTrue(baseArray._isEqual(to: [1, 2, 3]))

        XCTAssertFalse(baseArray._isEqual(to: [1, 2, 1]))
        XCTAssertFalse(baseArray._isEqual(to: [1, 3, 2]))
        XCTAssertFalse(baseArray._isEqual(to: [1, 2, 3, 4]))
        XCTAssertFalse(baseArray._isEqual(to: [1, 2]))
    }

    func test_array_Element_does_NOT_conforms_to_SpryEquatable() {
        XCTAssertThrowsAssertion {
            let notSpryEquatable = NotSpryEquatable()
            _ = [notSpryEquatable].compare(with: [notSpryEquatable])
        }
    }

    func test_dictionary_Value_conforms_to_SpryEquatable() {
        let baseDict = [
            "1": 1,
            "2": 2
        ]

        XCTAssertTrue(baseDict._isEqual(to: ["1": 1, "2": 2]))
        XCTAssertTrue(baseDict._isEqual(to: ["2": 2, "1": 1]))

        XCTAssertFalse(baseDict._isEqual(to: ["1": 5, "2": 5]))
        XCTAssertFalse(baseDict._isEqual(to: ["1": 1, "2": 2, "3": 3]))
        XCTAssertFalse(baseDict._isEqual(to: ["1": 1]))

        XCTAssertFalse(baseDict._isEqual(to: [1: 1, 2: 2]))
        XCTAssertFalse(baseDict._isEqual(to: [1: 1, 2: 2]))
    }

    func test_dictionary_Value_does_NOT_conforms_to_SpryEquatable() {
        XCTAssertThrowsAssertion {
            let notSpryEquatable: Any = NotSpryEquatable()
            _ = [1: notSpryEquatable].compare(with: [1: notSpryEquatable])
        }
    }

    func test_set_Value_conforms_to_SpryEquatable() {
        let baseDict: Set<String> = [
            "1",
            "2"
        ]

        XCTAssertTrue(baseDict._isEqual(to: Set(["1", "2"])))
        XCTAssertTrue(baseDict._isEqual(to: Set(["2", "1"])))

        XCTAssertFalse(baseDict._isEqual(to: Set([1, 2])))
        XCTAssertFalse(baseDict._isEqual(to: Set([2, 1])))
    }

    func test_optional() {
        var a: Int?
        var b: Int?
        var c: Int = 2
        let d: String? = nil
        let e: String = "e"

        XCTAssertTrue(a._isEqual(to: b))
        a = 0
        XCTAssertFalse(a._isEqual(to: b))
        b = 1
        XCTAssertFalse(a._isEqual(to: b))
        b = 2
        XCTAssertFalse(a._isEqual(to: b))
        a = 2
        XCTAssertTrue(a._isEqual(to: b))

        XCTAssertTrue(a._isEqual(to: c))
        XCTAssertTrue(c._isEqual(to: b))

        c = 0
        XCTAssertFalse(a._isEqual(to: c))
        XCTAssertFalse(c._isEqual(to: b))

        XCTAssertFalse(c._isEqual(to: d))
        XCTAssertFalse(d._isEqual(to: c))
        XCTAssertFalse(a._isEqual(to: d))
        XCTAssertFalse(d._isEqual(to: a))

        XCTAssertFalse(c._isEqual(to: e))
        XCTAssertFalse(e._isEqual(to: c))
        XCTAssertFalse(a._isEqual(to: e))
        XCTAssertFalse(e._isEqual(to: a))
    }
}
