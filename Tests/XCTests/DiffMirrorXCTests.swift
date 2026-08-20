import Foundation
import SpryKit
import XCTest

final class DiffMirrorXCTests: XCTestCase {
    func test_equal_values_produce_no_diff() {
        XCTAssertTrue(Spry.diffMirror(1, 1).isEmpty)
        XCTAssertTrue(Spry.diffMirror("same", "same").isEmpty)
        XCTAssertTrue(Spry.diffMirror(DiffPerson.john, DiffPerson.john).isEmpty)
        XCTAssertTrue(Spry.diffMirror([1, 2, 3], [1, 2, 3]).isEmpty)
        XCTAssertTrue(Spry.diffMirror(["a": 1], ["a": 1]).isEmpty)
        XCTAssertTrue(Spry.diffMirror(Set([1, 2]), Set([1, 2])).isEmpty)
        XCTAssertTrue(Spry.diffMirror(Decimal(1), Decimal(1)).isEmpty)
    }

    func test_primitives_collapse_into_a_single_entry() {
        let subject = Spry.diffMirror(2, 3)

        XCTAssertEqual(subject.count, 1)
        XCTAssertEqual(subject.first, "Received: 3\nExpected: 2\n")
    }

    func test_nested_structs_report_every_differing_field() {
        let subject = Spry.diffMirror(DiffPerson.john, DiffPerson.jane).joined()

        XCTAssertTrue(subject.contains("name:"))
        XCTAssertTrue(subject.contains("Received: Jane"))
        XCTAssertTrue(subject.contains("Expected: John"))
        XCTAssertTrue(subject.contains("street:"))
        XCTAssertTrue(subject.contains("Received: Second"))
        XCTAssertTrue(subject.contains("Expected: First"))
        XCTAssertFalse(subject.contains("zip:"))
    }

    func test_class_properties_are_compared() {
        let subject = Spry.diffMirror(DiffNode(id: 1), DiffNode(id: 2)).joined()

        XCTAssertTrue(subject.contains("id:"))
        XCTAssertTrue(subject.contains("Received: 2"))
        XCTAssertTrue(subject.contains("Expected: 1"))
    }

    func test_enum_cases_without_associated_values() {
        let subject = Spry.diffMirror(DiffShape.circle, DiffShape.square).joined()

        XCTAssertTrue(subject.contains("Received: square"))
        XCTAssertTrue(subject.contains("Expected: circle"))
    }

    func test_enum_case_with_associated_values_reports_only_the_differing_member() {
        let subject = Spry.diffMirror(DiffShape.rect(w: 1, h: 2), DiffShape.rect(w: 1, h: 3)).joined()

        XCTAssertTrue(subject.contains("Enum rect:"))
        XCTAssertTrue(subject.contains("h:"))
        XCTAssertTrue(subject.contains("Received: 3"))
        XCTAssertTrue(subject.contains("Expected: 2"))
        XCTAssertFalse(subject.contains("w:"))
    }

    func test_different_enum_cases_print_labels_instead_of_whole_payloads() {
        let subject = Spry.diffMirror(DiffShape.circle, DiffShape.rect(w: 1, h: 2)).joined()

        XCTAssertTrue(subject.contains("Received: rect"))
        XCTAssertTrue(subject.contains("circle"))
        XCTAssertFalse(subject.contains("h:"))
    }

    func test_collection_of_equal_count_reports_the_differing_index() {
        let subject = Spry.diffMirror([1, 2, 3], [1, 9, 3]).joined()

        XCTAssertTrue(subject.contains("Collection[1]"))
        XCTAssertTrue(subject.contains("Received: 9"))
        XCTAssertTrue(subject.contains("Expected: 2"))
    }

    func test_collection_of_different_count_reports_the_counts() {
        let subject = Spry.diffMirror([1, 2], [1, 2, 3]).joined()

        XCTAssertTrue(subject.contains("Different count:"))
        XCTAssertTrue(subject.contains("(3)"))
        XCTAssertTrue(subject.contains("(2)"))
        XCTAssertTrue(subject.contains("[1, 2, 3]"))
    }

    func test_skipPrintingOnDiffCount_omits_the_payload() {
        let subject = Spry.diffMirror([1, 2], [1, 2, 3], skipPrintingOnDiffCount: true).joined()

        XCTAssertTrue(subject.contains("Different count:"))
        XCTAssertTrue(subject.contains("(3)"))
        XCTAssertFalse(subject.contains("[1, 2, 3]"))
    }

    func test_empty_collection_is_reported_as_a_different_count() {
        let subject = Spry.diffMirror([Int](), [1]).joined()

        XCTAssertTrue(subject.contains("Different count:"))
        XCTAssertTrue(subject.contains("(0)"))
        XCTAssertTrue(subject.contains("(1)"))
    }

    func test_dictionary_reports_a_differing_value_by_key() {
        let subject = Spry.diffMirror(["a": 1, "b": 2], ["a": 1, "b": 3]).joined()

        XCTAssertTrue(subject.contains("Key b:"))
        XCTAssertTrue(subject.contains("Received: 3"))
        XCTAssertTrue(subject.contains("Expected: 2"))
        XCTAssertFalse(subject.contains("Key a:"))
    }

    func test_dictionary_reports_missing_and_extra_key_pairs() {
        let subject = Spry.diffMirror(["a": 1, "b": 2], ["a": 1, "c": 3]).joined()

        XCTAssertTrue(subject.contains("Missing key pairs:"))
        XCTAssertTrue(subject.contains("Extra key pairs:"))
        XCTAssertTrue(subject.contains("b:"))
        XCTAssertTrue(subject.contains("c:"))
    }

    func test_dictionary_of_different_count_reports_the_counts() {
        let subject = Spry.diffMirror(["a": 1], ["a": 1, "b": 2]).joined()

        XCTAssertTrue(subject.contains("Different count:"))
    }

    func test_set_reports_missing_and_extra_members() {
        let subject = Spry.diffMirror(Set([1, 2]), Set([2, 3])).joined()

        XCTAssertTrue(subject.contains("Missing: 1"))
        XCTAssertTrue(subject.contains("Extra: 3"))
    }

    func test_set_of_different_count_reports_the_counts() {
        let subject = Spry.diffMirror(Set([1]), Set([1, 2])).joined()

        XCTAssertTrue(subject.contains("Different count:"))
    }

    func test_optionals_are_unwrapped_before_comparing() {
        let subject = Spry.diffMirror(Optional(1), Optional(2)).joined()

        XCTAssertTrue(subject.contains("Received: 2"))
        XCTAssertTrue(subject.contains("Expected: 1"))
        XCTAssertFalse(subject.contains("some"))
        XCTAssertTrue(Spry.diffMirror(Int?.none, Int?.none).isEmpty)
    }

    func test_decimal_is_compared_by_value() {
        let subject = Spry.diffMirror(Decimal(1), Decimal(2)).joined()

        XCTAssertTrue(subject.contains("Received: 2"))
        XCTAssertTrue(subject.contains("Expected: 1"))
    }

    func test_tab_indentation_replaces_the_pipe() {
        let piped = Spry.diffMirror(DiffPerson.john, DiffPerson.jane).joined()
        let tabbed = Spry.diffMirror(DiffPerson.john, DiffPerson.jane, indentationType: .tab).joined()

        XCTAssertTrue(piped.contains("|\t"))
        XCTAssertFalse(tabbed.contains("|\t"))
        XCTAssertTrue(tabbed.contains("\tReceived: Jane"))
    }

    func test_comparing_labels_replace_the_expectation_labels() {
        let subject = Spry.diffMirror(2, 3, nameLabels: .comparing).joined()

        XCTAssertTrue(subject.contains("Current: 3"))
        XCTAssertTrue(subject.contains("Previous: 2"))
        XCTAssertFalse(subject.contains("Received"))
        XCTAssertFalse(subject.contains("Expected"))

        let keys = Spry.diffMirror(["a": 1, "b": 2], ["a": 1, "c": 3], nameLabels: .comparing).joined()
        XCTAssertTrue(keys.contains("Removed key pairs:"))
        XCTAssertTrue(keys.contains("Added key pairs:"))
    }

    func test_custom_labels_are_honoured() {
        let labels = SpryDiffNameLabels(expected: "Was", received: "Now", missing: "Gone", extra: "New")
        let subject = Spry.diffMirror(2, 3, nameLabels: labels).joined()

        XCTAssertTrue(subject.contains("Now: 3"))
        XCTAssertTrue(subject.contains("Was: 2"))
    }

    func test_lines_expose_the_tree_before_rendering() throws {
        let lines = Spry.diffMirrorLines(DiffPerson.john, DiffPerson.jane)

        XCTAssertEqual(lines.count, 2)

        let name = try XCTUnwrap(lines.first { $0.contents == "name:" })
        XCTAssertEqual(name.indentationLevel, 0)
        XCTAssertTrue(name.canBeOrdered)
        XCTAssertTrue(name.hasChildren)
        XCTAssertEqual(name.children.count, 2)
        XCTAssertTrue(name.children.allSatisfy { !$0.canBeOrdered })
        XCTAssertTrue(name.children.allSatisfy { !$0.hasChildren })
        XCTAssertTrue(name.children.allSatisfy { $0.indentationLevel == 1 })

        XCTAssertEqual(name.generateContents(indentationType: .pipe), "name:\n|\tReceived: Jane\n|\tExpected: John\n")
        XCTAssertEqual(name.generateContents(indentationType: .tab), "name:\n\tReceived: Jane\n\tExpected: John\n")
    }

    func test_a_leaf_line_renders_without_children() {
        let subject = SpryDiffLine(contents: "leaf", indentationLevel: 2, canBeOrdered: true)

        XCTAssertFalse(subject.hasChildren)
        XCTAssertTrue(subject.children.isEmpty)
        XCTAssertEqual(subject.generateContents(indentationType: .pipe), "|\t|\tleaf\n")
        XCTAssertEqual(subject.generateContents(indentationType: .tab), "\t\tleaf\n")
    }

    func test_indentation_raw_values() {
        XCTAssertEqual(SpryDiffIndentationType.pipe.rawValue, "|\t")
        XCTAssertEqual(SpryDiffIndentationType.tab.rawValue, "\t")
        XCTAssertEqual(SpryDiffIndentationType.allCases.count, 2)
    }
}

private struct DiffAddress {
    let street: String
    let zip: Int
}

private struct DiffPerson {
    let name: String
    let address: DiffAddress

    static let john = DiffPerson(name: "John", address: .init(street: "First", zip: 1))
    static let jane = DiffPerson(name: "Jane", address: .init(street: "Second", zip: 1))
}

private enum DiffShape {
    case circle
    case square
    case rect(w: Int, h: Int)
}

private final class DiffNode {
    let id: Int

    init(id: Int) {
        self.id = id
    }
}
