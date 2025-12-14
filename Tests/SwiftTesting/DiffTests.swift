#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Diff Tests", .serialized)
struct DiffTests {
    struct TestModel: Codable, Equatable {
        let id: Int
        let name: String
    }

    @Test("Diff texts equal strings returns empty")
    func diffTexts_equalStrings_returnsEmpty() {
        let lhs = "line1\nline2"
        let rhs = "line1\nline2"
        let result = Spry.diffLines(lhs, rhs)
        #expect(result == "")
    }

    @Test("Diff texts different strings returns diff")
    func diffTexts_differentStrings_returnsDiff() {
        let lhs = "line1\nline2"
        let rhs = "line1\nline3"
        let result = Spry.diffLines(lhs, rhs)
        #expect(result == """
          line1
        − line2
        + line3
        """)
    }

    @Test("Diff any strings different strings returns diff")
    func diffAnyStrings_differentStrings_returnsDiff() {
        let lhs: Any = "line1\nline2"
        let rhs: Any = "line1\nline3"
        let result = Spry.diffLines(String(describing: lhs), String(describing: rhs))
        #expect(result == """
          line1
        − line2
        + line3
        """)
    }

    @Test("Diff any different strings returns diff")
    func diffAny_differentStrings_returnsDiff() {
        let lhs: Any = "line2"
        let rhs: Any = "line3"
        let result = Spry.diffLines(String(describing: lhs), String(describing: rhs))
        #expect(result == """
        − line2
        + line3
        """)
    }

    @Test("Diff encodable equal models returns empty")
    func diffEncodable_equalModels_returnsEmpty() {
        let lhs = TestModel(id: 1, name: "A")
        let rhs = TestModel(id: 1, name: "A")
        let result = Spry.diffEncodable(lhs, rhs)
        #expect(result == "")
    }

    @Test("Diff encodable different models returns diff")
    func diffEncodable_differentModels_returnsDiff() {
        let lhs = TestModel(id: 1, name: "A")
        let rhs = TestModel(id: 2, name: "B")
        let result = Spry.diffEncodable(lhs, rhs)
        #expect(result == """
          {
        −   "id" : 1,
        −   "name" : "A"
        +   "id" : 2,
        +   "name" : "B"
          }
        """)
    }

    @Test("Diff encodable nil and non nil returns full diff")
    func diffEncodable_nilAndNonNil_returnsFullDiff() {
        let lhs: TestModel? = nil
        let rhs = TestModel(id: 42, name: "Zed")
        let result = Spry.diffEncodable(lhs, rhs)
        // Note: diffEncodable encodes nil as "null" (JSON format) when using JSONEncoder
        #expect(result == """
        − null
        + {
        +   "id" : 42,
        +   "name" : "Zed"
        + }
        """)
    }

    @Test("Diff encodable both nil returns empty")
    func diffEncodable_bothNil_returnsEmpty() {
        let lhs: TestModel? = nil
        let rhs: TestModel? = nil
        let result = Spry.diffEncodable(lhs, rhs)
        #expect(result == "")
    }

    @Test("Diff texts empty vs non empty returns diff")
    func diffTexts_emptyVsNonEmpty_returnsDiff() {
        let lhs = ""
        let rhs = "line1\nline2"
        let result = Spry.diffLines(lhs, rhs)
        #expect(result == """
        − 
        + line1
        + line2
        """)
    }

    @Test("Diff texts emoji and unicode returns diff")
    func diffTexts_emojiAndUnicode_returnsDiff() {
        let lhs = "Hello 👋\nCafé"
        let rhs = "Hello 👋\nCafe"
        let result = Spry.diffLines(lhs, rhs)
        #expect(result == """
          Hello 👋
        − Café
        + Cafe
        """)
    }

    @Test("Diff encodable with custom encoder mentions changed key")
    func diffEncodable_withCustomEncoder_mentionsChangedKey() {
        struct User: Encodable {
            let id: Int
            let name: String
        }
        let lhs = User(id: 1, name: "Alice")
        let rhs = User(id: 1, name: "Bob")

        let encoder = JSONEncoder()
        if #available(iOS 13.0, macOS 10.15, *) {
            encoder.outputFormatting = [JSONEncoder.OutputFormatting.sortedKeys, JSONEncoder.OutputFormatting.withoutEscapingSlashes]
        }
        encoder.outputFormatting.insert(JSONEncoder.OutputFormatting.prettyPrinted)

        let result = Spry.diffEncodable(lhs, rhs, encoder: encoder)
        #expect(result == """
          {
            "id" : 1,
        −   "name" : "Alice"
        +   "name" : "Bob"
          }
        """)
    }

    @Test("Diff encodable array with changed element returns diff")
    func diffEncodable_arrayWithChangedElement_returnsDiff() {
        struct Item: Codable { let id: Int
            let title: String
        }
        let lhs = [Item(id: 1, title: "A"), Item(id: 2, title: "B")]
        let rhs = [Item(id: 1, title: "A"), Item(id: 2, title: "Bee")] // changed title
        let result = Spry.diffEncodable(lhs, rhs)
        #expect(result == """
          [
            {
              "id" : 1,
              "title" : "A"
            },
            {
              "id" : 2,
        −     "title" : "B"
        +     "title" : "Bee"
            }
          ]
        """)
    }

    @Test("Diff encodable optional nil to nil returns empty")
    func diffEncodable_optionalNilToNil_returnsEmpty() {
        struct Blob: Codable { let value: String }
        let lhs: Blob? = nil
        let rhs: Blob? = nil
        let result = Spry.diffEncodable(lhs, rhs)
        #expect(result == "")
    }

    @Test("Diff texts single insertion returns diff")
    func diffTexts_singleInsertion_returnsDiff() {
        let lhs = "a\nb\nd"
        let rhs = "a\nb\nc\nd" // inserted c
        let result = Spry.diffLines(lhs, rhs)
        #expect(result == """
          a
          b
        + c
          d
        """)
    }
}
#endif // canImport(Testing)
