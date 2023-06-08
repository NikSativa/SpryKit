import Foundation
import NSpry
import XCTest

final class AnyEquatableTests: XCTestCase {
    func test_int() {
        check(a: 1, b: 2)
    }

    func test_double() {
        check(a: 1.0, b: 2)
    }

    func test_string() {
        check(a: "1.0", b: "2")
    }

    func test_date() {
        let now = Date()
        check(a: now, b: now.addingTimeInterval(1000))
    }

    func test_array() {
        check(a: [1], b: [2])
        check(a: [1, 2], b: [2])
        check(a: [1, 2], b: [2, 1])
        check(a: [1, 3], b: [2])
    }

    func test_dictionary() {
        check(a: ["1": 1], b: ["2": 2])
        check(a: ["1": 1], b: ["2": 1])
        check(a: ["1": 2], b: ["2": 2])
        check(a: ["1": 1, "2": 2], b: ["2": 2])
        check(a: ["1": 1, "3": 3], b: ["2": 2])
    }

    func test_set() {
        check(a: Set([1]), b: Set([2]))
        check(a: Set([1, 2]), b: Set([2]))
        check(a: Set([1, 3]), b: Set([2]))
    }

    func test_tuple() {
        let a: (l: String, r: Int) = ("a", 1)
        let b: (l: String, r: Int) = ("b", 2)
        let c: (r: Int, l: String) = (1, "a")
        let d: (l: Int, r: String) = (1, "a")
        let e: (l1: String, r1: Int) = ("a", 1)

        check(a: a, b: b)

        XCTAssertFalse(isAnyEqual(a, c), "a != c")
        XCTAssertFalse(isAnyEqual(a, d), "a != d")

        XCTAssertTrue(isAnyEqual(a, e), "a != e")
        XCTAssertTrue(a == e, "a != e")
    }

    func test_empty_object() {
        XCTAssertTrue(isAnyEqual(EmptyObject(), EmptyObject()))
        XCTAssertFalse(isAnyEqual(EmptyObject(), AnyObject(p: 1)))
        XCTAssertFalse(isAnyEqual(EmptyObject(), EmptyStruct()))
    }

    func test_objects() {
        XCTAssertTrue(isAnyEqual(AnyObject(p: 1), AnyObject(p: 1)))
        XCTAssertFalse(isAnyEqual(AnyObject(p: 1), AnyObject(p: 2)))
        XCTAssertFalse(isAnyEqual(AnyObject(p: 1), AnyStruct(p: 2)))
    }

    func test_empty_struct() {
        XCTAssertTrue(isAnyEqual(EmptyStruct(), EmptyStruct()))
        XCTAssertFalse(isAnyEqual(EmptyStruct(), AnyObject(p: 1)))
        XCTAssertFalse(isAnyEqual(EmptyStruct(), EmptyObject()))
    }

    func test_structs() {
        XCTAssertTrue(isAnyEqual(AnyStruct(p: 1), AnyStruct(p: 1)))
        XCTAssertFalse(isAnyEqual(AnyStruct(p: 1), AnyStruct(p: 2)))
        XCTAssertFalse(isAnyEqual(AnyStruct(p: 1), AnyObject(p: 2)))
    }

    func test_enum() {
        check(a: AnyEnum.one, b: AnyEnum.two)
        check(a: AnyEnum.three("str"), b: AnyEnum.one)
        check(a: AnyEnum.three("str"), b: AnyEnum.six("str"))
        check(a: AnyEnum.four(l: "str2"), b: AnyEnum.one)
        check(a: AnyEnum.five(l: "str2", r: 1), b: AnyEnum.one)

        XCTAssertFalse(isAnyEqual(AnyEnum.one, AnyEnum2.one))

        XCTAssertTrue(isAnyEqual(AnyEnum.three("str"), AnyEnum.three("str")))
        XCTAssertFalse(isAnyEqual(AnyEnum.three("str"), AnyEnum.three("str2")))

        XCTAssertFalse(isAnyEqual(AnyEnum.three("str"), AnyEnum.six("str")))
        XCTAssertFalse(isAnyEqual(AnyEnum.three("str"), AnyEnum.six("str2")))

        XCTAssertTrue(isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.four(l: "str")))
        XCTAssertFalse(isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.four(l: "str2")))

        XCTAssertFalse(isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.six("str")))
        XCTAssertFalse(isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.six("str2")))

        XCTAssertFalse(isAnyEqual(AnyEnum.four(l: "str"), AnyEnum2.four(l: "str")))
        XCTAssertFalse(isAnyEqual(AnyEnum.four(l: "str"), AnyEnum2.four(l: "str2")))
    }

    private func check<T>(a: T, b: T, file: StaticString = #filePath, line: UInt = #line) {
        let aO: T? = a
        let bO: T? = b

        XCTAssertTrue(isAnyEqual(a, a), "a == a", file: file, line: line)
        XCTAssertFalse(isAnyEqual(a, b), "a != b", file: file, line: line)

        XCTAssertTrue(isAnyEqual(a, aO as Any), "a == aO", file: file, line: line)
        XCTAssertFalse(isAnyEqual(a, bO as Any), "a != bO", file: file, line: line)
    }
}

private final class EmptyObject {}
private final class AnyObject {
    let p: Int

    init(p: Int) {
        self.p = p
    }
}

private struct EmptyStruct {}
private struct AnyStruct {
    let p: Int
}

private enum AnyEnum {
    case one
    case two

    case three(String)
    case four(l: String)
    case five(l: String, r: Int)
    case six(String)
}

private enum AnyEnum2 {
    case one
    case four(l: String)
}
