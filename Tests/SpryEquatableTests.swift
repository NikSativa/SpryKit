import Foundation
import NSpry
import XCTest

final class SpryEquatableTests: XCTestCase {
    let subject: SpyableTestHelper = .init()

    override func setUp() {
        super.setUp()
        subject.resetCalls()
        SpyableTestHelper.resetCalls()
    }

    func test_NOT_Equatable_and_AnyObject() {
        let myObject1 = AnyObjectOnly()
        let myObject2 = AnyObjectOnly()

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
            _ = [notSpryEquatable]._isEqual(to: [notSpryEquatable])
        }
    }

    func test_dictionary_Value_conforms_to_SpryEquatable() {
        let baseDict = [
            1: 1,
            2: 2
        ]

        XCTAssertTrue(baseDict._isEqual(to: [1: 1, 2: 2] as SpryEquatable))
        XCTAssertTrue(baseDict._isEqual(to: [2: 2, 1: 1] as SpryEquatable))

        XCTAssertFalse(baseDict._isEqual(to: [1: 5, 2: 5] as SpryEquatable))
        XCTAssertFalse(baseDict._isEqual(to: [1: 1, 2: 2, 3: 3] as SpryEquatable))
        XCTAssertFalse(baseDict._isEqual(to: [1: 1] as SpryEquatable))
    }

    func test_dictionary_Value_does_NOT_conforms_to_SpryEquatable() {
        XCTAssertThrowsAssertion {
            let notSpryEquatable = NotSpryEquatable()
            _ = [1: notSpryEquatable]._isEqual(to: [1: notSpryEquatable])
        }
    }
}
