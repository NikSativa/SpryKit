import SpryKit
import XCTest

final class DiffTests: XCTestCase {
    struct TestModel: Codable, Equatable {
        let id: Int
        let name: String
    }

    func testDiffTexts_equalStrings_returnsEmpty() {
        let lhs = "line1\nline2"
        let rhs = "line1\nline2"
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, "")
    }

    func testDiffTexts_differentStrings_returnsDiff() {
        let lhs = "line1\nline2"
        let rhs = "line1\nline3"
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
          line1
        − line2
        + line3
        """)
    }

    func testDiffAnyStrings_differentStrings_returnsDiff() {
        let lhs: Any = "line1\nline2"
        let rhs: Any = "line1\nline3"
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
          line1
        − line2
        + line3
        """)
    }

    func testDiffAny_differentStrings_returnsDiff() {
        let lhs: Any = "line2"
        let rhs: Any = "line3"
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
        − line2
        + line3
        """)
    }

    func testDiffEncodable_equalModels_returnsEmpty() {
        let lhs = TestModel(id: 1, name: "A")
        let rhs = TestModel(id: 1, name: "A")
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, "")
    }

    func testDiffEncodable_differentModels_returnsDiff() {
        let lhs = TestModel(id: 1, name: "A")
        let rhs = TestModel(id: 2, name: "B")
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
          {
        −   "id" : 1,
        −   "name" : "A"
        +   "id" : 2,
        +   "name" : "B"
          }
        """)
    }

    func testDiffEncodable_nilAndNonNil_returnsFullDiff() {
        let lhs: TestModel? = nil
        let rhs = TestModel(id: 42, name: "Zed")
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
        − nil
        + {
        +   "id" : 42,
        +   "name" : "Zed"
        + }
        """)
    }

    func testDiffEncodable_bothNil_returnsEmpty() {
        let lhs: TestModel? = nil
        let rhs: TestModel? = nil
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, "")
    }

    func testDiffTexts_emptyVsNonEmpty_returnsDiff() {
        let lhs = ""
        let rhs = "line1\nline2"
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
        − 
        + line1
        + line2
        """)
    }

    func testDiffTexts_emojiAndUnicode_returnsDiff() {
        let lhs = "Hello 👋\nCafé"
        let rhs = "Hello 👋\nCafe"
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
          Hello 👋
        − Café
        + Cafe
        """)
    }

    func testDiffEncodable_withCustomEncoder_mentionsChangedKey() {
        struct User: Encodable {
            let id: Int
            let name: String
        }
        let lhs = User(id: 1, name: "Alice")
        let rhs = User(id: 1, name: "Bob")

        let encoder = JSONEncoder()
        if #available(iOS 13.0, macOS 10.15, *) {
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        }
        encoder.outputFormatting.insert(.prettyPrinted)

        let result = Spry.diff(lhs, rhs, encoder: encoder)
        XCTAssertEqual(result, """
          {
            "id" : 1,
        −   "name" : "Alice"
        +   "name" : "Bob"
          }
        """)
    }

    func testDiffEncodable_arrayWithChangedElement_returnsDiff() {
        struct Item: Codable { let id: Int
            let title: String
        }
        let lhs = [Item(id: 1, title: "A"), Item(id: 2, title: "B")]
        let rhs = [Item(id: 1, title: "A"), Item(id: 2, title: "Bee")] // changed title
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
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

    func testDiffEncodable_optionalNilToNil_returnsEmpty() {
        struct Blob: Codable { let value: String }
        let lhs: Blob? = nil
        let rhs: Blob? = nil
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, "")
    }

    func testDiffTexts_singleInsertion_returnsDiff() {
        let lhs = "a\nb\nd"
        let rhs = "a\nb\nc\nd" // inserted c
        let result = Spry.diff(lhs, rhs)
        XCTAssertEqual(result, """
          a
          b
        + c
          d
        """)
    }

    // MARK: - Helpers

    private func makeText(lineCount: Int, changeAt index: Int?) -> (lhs: String, rhs: String) {
        precondition(lineCount > 0)
        var lhsLines: [String] = []
        lhsLines.reserveCapacity(lineCount)
        var rhsLines: [String] = []
        rhsLines.reserveCapacity(lineCount)
        for i in 0..<lineCount {
            let base = "line_\(i)"
            lhsLines.append(base)
            if let idx = index, idx == i {
                rhsLines.append(base + "_changed")
            } else {
                rhsLines.append(base)
            }
        }
        return (lhsLines.joined(separator: "\n"), rhsLines.joined(separator: "\n"))
    }

    // MARK: - Performance

    func testDiffTexts_performance_small() {
        let pair = makeText(lineCount: 200, changeAt: 100)
        measure {
            _ = Spry.diff(pair.lhs, pair.rhs)
        }
    }

    func testDiffTexts_performance_medium() {
        let pair = makeText(lineCount: 2_000, changeAt: 1_000)
        measure {
            _ = Spry.diff(pair.lhs, pair.rhs)
        }
    }

    func testDiffTexts_performance_large() {
        // Large but still CI-friendly; adjust if needed
        let pair = makeText(lineCount: 10_000, changeAt: 5_000)
        measure {
            _ = Spry.diff(pair.lhs, pair.rhs)
        }
    }

    func testDiffEncodable_performance_array() {
        struct Node: Codable { let id: Int
            let text: String
        }
        let lhs = (0..<5_000).map { Node(id: $0, text: "\($0)") }
        let rhs = (0..<5_000).map { i in i == 2_500 ? Node(id: i, text: "changed") : Node(id: i, text: "\(i)") }
        measure {
            _ = Spry.diff(lhs, rhs)
        }
    }
}
