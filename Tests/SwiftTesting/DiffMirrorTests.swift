#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("DiffMirror Tests", .serialized)
struct DiffMirrorTests {
    @Test("Equal values produce no diff")
    func equal_values_produce_no_diff() {
        #expect(Spry.diffMirror(1, 1).isEmpty)
        #expect(Spry.diffMirror("same", "same").isEmpty)
        #expect(Spry.diffMirror(DiffPerson.john, DiffPerson.john).isEmpty)
        #expect(Spry.diffMirror([1, 2, 3], [1, 2, 3]).isEmpty)
        #expect(Spry.diffMirror(["a": 1], ["a": 1]).isEmpty)
        #expect(Spry.diffMirror(Set([1, 2]), Set([1, 2])).isEmpty)
        #expect(Spry.diffMirror(Decimal(1), Decimal(1)).isEmpty)
    }

    @Test("Primitives collapse into a single entry")
    func primitives_collapse_into_a_single_entry() {
        let subject = Spry.diffMirror(2, 3)

        #expect(subject.count == 1)
        #expect(subject[0] == "Received: 3\nExpected: 2\n")
    }

    @Test("Nested structs report every differing field")
    func nested_structs_report_every_differing_field() {
        let subject = Spry.diffMirror(DiffPerson.john, DiffPerson.jane).joined()

        #expect(subject.contains("name:"))
        #expect(subject.contains("Received: Jane"))
        #expect(subject.contains("Expected: John"))
        #expect(subject.contains("street:"))
        #expect(subject.contains("Received: Second"))
        #expect(subject.contains("Expected: First"))
        #expect(!subject.contains("zip:"))
    }

    @Test("Class properties are compared")
    func class_properties_are_compared() {
        let subject = Spry.diffMirror(DiffNode(id: 1), DiffNode(id: 2)).joined()

        #expect(subject.contains("id:"))
        #expect(subject.contains("Received: 2"))
        #expect(subject.contains("Expected: 1"))
    }

    @Test("Enum cases without associated values")
    func enum_cases_without_associated_values() {
        let subject = Spry.diffMirror(DiffShape.circle, DiffShape.square).joined()

        #expect(subject.contains("Received: square"))
        #expect(subject.contains("Expected: circle"))
    }

    @Test("Enum case with associated values reports only the differing member")
    func enum_case_with_associated_values_reports_only_the_differing_member() {
        let subject = Spry.diffMirror(DiffShape.rect(w: 1, h: 2), DiffShape.rect(w: 1, h: 3)).joined()

        #expect(subject.contains("Enum rect:"))
        #expect(subject.contains("h:"))
        #expect(subject.contains("Received: 3"))
        #expect(subject.contains("Expected: 2"))
        #expect(!subject.contains("w:"))
    }

    @Test("Different enum cases print labels instead of whole payloads")
    func different_enum_cases_print_labels_instead_of_whole_payloads() {
        let subject = Spry.diffMirror(DiffShape.circle, DiffShape.rect(w: 1, h: 2)).joined()

        #expect(subject.contains("Received: rect"))
        #expect(subject.contains("Expected: "))
        #expect(subject.contains("circle"))
        #expect(!subject.contains("h:"))
    }

    @Test("Collection of equal count reports the differing index")
    func collection_of_equal_count_reports_the_differing_index() {
        let subject = Spry.diffMirror([1, 2, 3], [1, 9, 3]).joined()

        #expect(subject.contains("Collection[1]"))
        #expect(subject.contains("Received: 9"))
        #expect(subject.contains("Expected: 2"))
    }

    @Test("Collection of different count reports the counts")
    func collection_of_different_count_reports_the_counts() {
        let subject = Spry.diffMirror([1, 2], [1, 2, 3]).joined()

        #expect(subject.contains("Different count:"))
        #expect(subject.contains("(3)"))
        #expect(subject.contains("(2)"))
        #expect(subject.contains("[1, 2, 3]"))
    }

    @Test("skipPrintingOnDiffCount omits the payload")
    func skipPrintingOnDiffCount_omits_the_payload() {
        let subject = Spry.diffMirror([1, 2], [1, 2, 3], skipPrintingOnDiffCount: true).joined()

        #expect(subject.contains("Different count:"))
        #expect(subject.contains("(3)"))
        #expect(!subject.contains("[1, 2, 3]"))
    }

    @Test("Empty collection is reported as a different count")
    func empty_collection_is_reported_as_a_different_count() {
        let subject = Spry.diffMirror([Int](), [1]).joined()

        #expect(subject.contains("Different count:"))
        #expect(subject.contains("(0)"))
        #expect(subject.contains("(1)"))
    }

    @Test("Dictionary reports a differing value by key")
    func dictionary_reports_a_differing_value_by_key() {
        let subject = Spry.diffMirror(["a": 1, "b": 2], ["a": 1, "b": 3]).joined()

        #expect(subject.contains("Key b:"))
        #expect(subject.contains("Received: 3"))
        #expect(subject.contains("Expected: 2"))
        #expect(!subject.contains("Key a:"))
    }

    @Test("Dictionary reports missing and extra key pairs")
    func dictionary_reports_missing_and_extra_key_pairs() {
        let subject = Spry.diffMirror(["a": 1, "b": 2], ["a": 1, "c": 3]).joined()

        #expect(subject.contains("Missing key pairs:"))
        #expect(subject.contains("Extra key pairs:"))
        #expect(subject.contains("b:"))
        #expect(subject.contains("c:"))
    }

    @Test("Dictionary of different count reports the counts")
    func dictionary_of_different_count_reports_the_counts() {
        let subject = Spry.diffMirror(["a": 1], ["a": 1, "b": 2]).joined()

        #expect(subject.contains("Different count:"))
    }

    @Test("Set reports missing and extra members")
    func set_reports_missing_and_extra_members() {
        let subject = Spry.diffMirror(Set([1, 2]), Set([2, 3])).joined()

        #expect(subject.contains("Missing: 1"))
        #expect(subject.contains("Extra: 3"))
    }

    @Test("Set of different count reports the counts")
    func set_of_different_count_reports_the_counts() {
        let subject = Spry.diffMirror(Set([1]), Set([1, 2])).joined()

        #expect(subject.contains("Different count:"))
    }

    @Test("Optionals are unwrapped before comparing")
    func optionals_are_unwrapped_before_comparing() {
        let subject = Spry.diffMirror(Optional(1), Optional(2)).joined()

        #expect(subject.contains("Received: 2"))
        #expect(subject.contains("Expected: 1"))
        #expect(!subject.contains("some"))
        let bothNone = Spry.diffMirror(Int?.none, Int?.none)
        #expect(bothNone.isEmpty)
    }

    @Test("Decimal is compared by value")
    func decimal_is_compared_by_value() {
        let subject = Spry.diffMirror(Decimal(1), Decimal(2)).joined()

        #expect(subject.contains("Received: 2"))
        #expect(subject.contains("Expected: 1"))
    }

    @Test("Tab indentation replaces the pipe")
    func tab_indentation_replaces_the_pipe() {
        let piped = Spry.diffMirror(DiffPerson.john, DiffPerson.jane).joined()
        let tabbed = Spry.diffMirror(DiffPerson.john, DiffPerson.jane, indentationType: .tab).joined()

        #expect(piped.contains("|\t"))
        #expect(!tabbed.contains("|\t"))
        #expect(tabbed.contains("\tReceived: Jane"))
    }

    @Test("Comparing labels replace the expectation labels")
    func comparing_labels_replace_the_expectation_labels() {
        let subject = Spry.diffMirror(2, 3, nameLabels: .comparing).joined()

        #expect(subject.contains("Current: 3"))
        #expect(subject.contains("Previous: 2"))
        #expect(!subject.contains("Received"))
        #expect(!subject.contains("Expected"))

        let keys = Spry.diffMirror(["a": 1, "b": 2], ["a": 1, "c": 3], nameLabels: .comparing).joined()
        #expect(keys.contains("Removed key pairs:"))
        #expect(keys.contains("Added key pairs:"))
    }

    @Test("Custom labels are honoured")
    func custom_labels_are_honoured() {
        let labels = SpryDiffNameLabels(expected: "Was", received: "Now", missing: "Gone", extra: "New")
        let subject = Spry.diffMirror(2, 3, nameLabels: labels).joined()

        #expect(subject.contains("Now: 3"))
        #expect(subject.contains("Was: 2"))
    }

    @Test("Lines expose the tree before rendering")
    func lines_expose_the_tree_before_rendering() throws {
        let lines = Spry.diffMirrorLines(DiffPerson.john, DiffPerson.jane)

        #expect(lines.count == 2)

        let name = try #require(lines.first { $0.contents == "name:" })
        #expect(name.indentationLevel == 0)
        #expect(name.canBeOrdered)
        #expect(name.hasChildren)
        #expect(name.children.count == 2)
        #expect(name.children.allSatisfy { !$0.canBeOrdered })
        #expect(name.children.allSatisfy { !$0.hasChildren })
        #expect(name.children.allSatisfy { $0.indentationLevel == 1 })

        #expect(name.generateContents(indentationType: .pipe) == "name:\n|\tReceived: Jane\n|\tExpected: John\n")
        #expect(name.generateContents(indentationType: .tab) == "name:\n\tReceived: Jane\n\tExpected: John\n")
    }

    @Test("A leaf line renders without children")
    func a_leaf_line_renders_without_children() {
        let subject = SpryDiffLine(contents: "leaf", indentationLevel: 2, canBeOrdered: true)

        #expect(!subject.hasChildren)
        #expect(subject.children.isEmpty)
        #expect(subject.generateContents(indentationType: .pipe) == "|\t|\tleaf\n")
        #expect(subject.generateContents(indentationType: .tab) == "\t\tleaf\n")
    }

    @Test("Indentation raw values")
    func indentation_raw_values() {
        #expect(SpryDiffIndentationType.pipe.rawValue == "|\t")
        #expect(SpryDiffIndentationType.tab.rawValue == "\t")
        #expect(SpryDiffIndentationType.allCases.count == 2)
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
#endif // canImport(Testing)
