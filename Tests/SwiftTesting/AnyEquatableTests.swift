#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("AnyEquatable Tests", .serialized)
struct AnyEquatableTests {
    @Test("Int")
    func int() {
        check(a: 1, b: 2)
    }

    @Test("Double")
    func double() {
        check(a: 1.0, b: 2)
    }

    @Test("String")
    func string() {
        check(a: "1.0", b: "2")
    }

    @Test("Date")
    func date() {
        let now = Date()
        check(a: now, b: now.addingTimeInterval(1000))
    }

    @Test("Array")
    func array() {
        check(a: [1], b: [2])
        check(a: [1, 2], b: [2])
        check(a: [1, 2], b: [2, 1])
        check(a: [1, 3], b: [2])
    }

    @Test("Dictionary")
    func dictionary() {
        check(a: ["1": 1], b: ["2": 2])
        check(a: ["1": 1], b: ["2": 1])
        check(a: ["1": 2], b: ["2": 2])
        check(a: ["1": 1, "2": 2], b: ["2": 2])
        check(a: ["1": 1, "3": 3], b: ["2": 2])
    }

    @Test("Set")
    func set() {
        check(a: Set([1]), b: Set([2]))
        check(a: Set([1, 2]), b: Set([2]))
        check(a: Set([1, 3]), b: Set([2]))
    }

    @Test("Tuple")
    func tuple() {
        let a: (l: String, r: Int) = ("a", 1)
        let b: (l: String, r: Int) = ("b", 2)
        let c: (r: Int, l: String) = (1, "a")
        let d: (l: Int, r: String) = (1, "a")
        let e: (l1: String, r1: Int) = ("a", 1)

        check(a: a, b: b)

        #expect(!isAnyEqual(a, c), "a != c")
        #expect(!isAnyEqual(a, d), "a != d")

        #expect(isAnyEqual(a, e), "a == e")
        #expect(a == e, "a == e")
    }

    @Test("Empty object")
    func empty_object() {
        #expect(isAnyEqual(EmptyObject(), EmptyObject()))
        #expect(!isAnyEqual(EmptyObject(), AnyObject(p: 1)))
        #expect(!isAnyEqual(EmptyObject(), EmptyStruct()))
    }

    @Test("Objects")
    func objects() {
        #expect(isAnyEqual(AnyObject(p: 1), AnyObject(p: 1)))
        #expect(!isAnyEqual(AnyObject(p: 1), AnyObject(p: 2)))
        #expect(!isAnyEqual(AnyObject(p: 1), AnyStruct(p: 2)))
    }

    @Test("Empty struct")
    func empty_struct() {
        #expect(isAnyEqual(EmptyStruct(), EmptyStruct()))
        #expect(!isAnyEqual(EmptyStruct(), AnyObject(p: 1)))
        #expect(!isAnyEqual(EmptyStruct(), EmptyObject()))
    }

    @Test("Structs")
    func structs() {
        #expect(isAnyEqual(AnyStruct(p: 1), AnyStruct(p: 1)))
        #expect(!isAnyEqual(AnyStruct(p: 1), AnyStruct(p: 2)))
        #expect(!isAnyEqual(AnyStruct(p: 1), AnyObject(p: 2)))
    }

    @Test("Enum")
    func enum_test() {
        check(a: AnyEnum.one, b: AnyEnum.two)
        check(a: AnyEnum.three("str"), b: AnyEnum.one)
        check(a: AnyEnum.three("str"), b: AnyEnum.six("str"))
        check(a: AnyEnum.four(l: "str2"), b: AnyEnum.one)
        check(a: AnyEnum.five(l: "str2", r: 1), b: AnyEnum.one)

        #expect(!isAnyEqual(AnyEnum.one, AnyEnum2.one))

        #expect(isAnyEqual(AnyEnum.three("str"), AnyEnum.three("str")))
        #expect(!isAnyEqual(AnyEnum.three("str"), AnyEnum.three("str2")))

        #expect(!isAnyEqual(AnyEnum.three("str"), AnyEnum.six("str")))
        #expect(!isAnyEqual(AnyEnum.three("str"), AnyEnum.six("str2")))

        #expect(isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.four(l: "str")))
        #expect(!isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.four(l: "str2")))

        #expect(!isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.six("str")))
        #expect(!isAnyEqual(AnyEnum.four(l: "str"), AnyEnum.six("str2")))

        #expect(!isAnyEqual(AnyEnum.four(l: "str"), AnyEnum2.four(l: "str")))
        #expect(!isAnyEqual(AnyEnum.four(l: "str"), AnyEnum2.four(l: "str2")))
    }

    private func check<T>(a: T, b: T) {
        let aO: T? = a
        let bO: T? = b

        #expect(isAnyEqual(a, a), "a == a")
        #expect(!isAnyEqual(a, b), "a != b")

        #expect(isAnyEqual(a, aO as Any), "a == aO")
        #expect(!isAnyEqual(a, bO as Any), "a != bO")
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
#endif // canImport(Testing)
