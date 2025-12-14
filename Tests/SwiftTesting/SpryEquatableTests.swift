#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("SpryEquatable Tests", .serialized)
struct SpryEquatableTests {
    @Test("NOT Equatable and AnyObject")
    func NOT_Equatable_and_AnyObject() {
        let myObject1 = AnyObjectOnly(p: 1)
        let myObject2 = AnyObjectOnly(p: 2)

        #expect(isAnyEqual(myObject1, myObject1))
        #expect(!isAnyEqual(myObject1, myObject2))
    }

    @Test("Equatable and AnyObject")
    func Equatable_and_AnyObject() {
        let myObject1 = AnyObjectAndEquatable()
        let myObject2 = AnyObjectAndEquatable()

        #expect(isAnyEqual(myObject1, myObject1))
        #expect(isAnyEqual(myObject1, myObject2))
    }

    @Test("Array Element conforms to SpryEquatable")
    func array_Element_conforms_to_SpryEquatable() {
        let baseArray = [1, 2, 3]

        #expect(isAnyEqual(baseArray, [1, 2, 3]))

        #expect(!isAnyEqual(baseArray, [1, 2, 1]))
        #expect(!isAnyEqual(baseArray, [1, 3, 2]))
        #expect(!isAnyEqual(baseArray, [1, 2, 3, 4]))
        #expect(!isAnyEqual(baseArray, [1, 2]))
    }

    @Test("Dictionary Value conforms to SpryEquatable")
    func dictionary_Value_conforms_to_SpryEquatable() {
        let baseDict = [
            "1": 1,
            "2": 2
        ]

        #expect(isAnyEqual(baseDict, ["1": 1, "2": 2]))
        #expect(isAnyEqual(baseDict, ["2": 2, "1": 1]))

        #expect(!isAnyEqual(baseDict, ["1": 5, "2": 5]))
        #expect(!isAnyEqual(baseDict, ["1": 1, "2": 2, "3": 3]))
        #expect(!isAnyEqual(baseDict, ["1": 1]))

        #expect(!isAnyEqual(baseDict, [1: 1, 2: 2]))
        #expect(!isAnyEqual(baseDict, [1: 1, 2: 2]))
    }

    @Test("Set Value conforms to SpryEquatable")
    func set_Value_conforms_to_SpryEquatable() {
        let baseDict: Set<String> = [
            "1",
            "2"
        ]

        #expect(isAnyEqual(baseDict, Set(["1", "2"])))
        #expect(isAnyEqual(baseDict, Set(["2", "1"])))

        #expect(!isAnyEqual(baseDict, Set([1, 2])))
        #expect(!isAnyEqual(baseDict, Set([2, 1])))
    }

    @Test("Optional")
    func optional() {
        var a: Int?
        var b: Int?
        var c = 2
        let d: String? = nil
        let e = "e"

        #expect(isAnyEqual(a, b))
        a = 0
        #expect(!isAnyEqual(a, b))
        b = 1
        #expect(!isAnyEqual(a, b))
        b = 2
        #expect(!isAnyEqual(a, b))
        a = 2
        #expect(isAnyEqual(a, b))

        #expect(isAnyEqual(a, c))
        #expect(isAnyEqual(c, b))

        c = 0
        #expect(!isAnyEqual(a, c))
        #expect(!isAnyEqual(c, b))

        #expect(!isAnyEqual(c, d))
        #expect(!isAnyEqual(d, c))
        #expect(!isAnyEqual(a, d))
        #expect(!isAnyEqual(d, a))

        #expect(!isAnyEqual(c, e))
        #expect(!isAnyEqual(e, c))
        #expect(!isAnyEqual(a, e))
        #expect(!isAnyEqual(e, a))
    }
}
#endif // canImport(Testing)
