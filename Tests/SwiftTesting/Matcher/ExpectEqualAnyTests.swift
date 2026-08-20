#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectEqualAny Tests", .serialized)
struct ExpectEqualAnyTests {
    private enum Error: Swift.Error {
        case one
        case two
    }

    @Test("Errors")
    func errors() {
        expectEqualAny(1, 1)
        expectEqualAny([1], [1])

        expectNotEqualAny(2, 1)
        expectNotEqualAny([2: 1], [1: 1])
    }

    @Test("Failure message describes both sides and the diff")
    func failure_message_describes_both_sides_and_the_diff() {
        withKnownIssue {
            expectEqualAny(EncodablePayload(name: "John"), EncodablePayload(name: "Jane"))
        } matching: { issue in
            issue.description.contains("\"name\" : \"John\"")
                && issue.description.contains("\"name\" : \"Jane\"")
                && issue.description.contains("is not equal to")
                && issue.description.contains("diff:")
                && issue.description.contains("Received: Jane")
        }
    }

    @Test("Failure message falls back to a plain description")
    func failure_message_falls_back_to_a_plain_description() {
        withKnownIssue {
            expectEqualAny(PlainPayload(name: "John"), PlainPayload(name: "Jane"))
        } matching: { issue in
            issue.description.contains("PlainPayload(name: \"John\")")
                && issue.description.contains("PlainPayload(name: \"Jane\")")
        }
    }

    @Test("Failure message describes nil")
    func failure_message_describes_nil() {
        withKnownIssue {
            expectEqualAny(nil as Int?, 5)
        } matching: { issue in
            issue.description.contains("(\"nil\")") && issue.description.contains("(\"5\")")
        }
    }

    @Test("A custom message replaces the generated one")
    func a_custom_message_replaces_the_generated_one() {
        withKnownIssue {
            expectEqualAny(1, 2, "values must match")
        } matching: { issue in
            issue.description.contains("values must match") && !issue.description.contains("diff:")
        }
    }

    @Test("Not-equal failure reports equality")
    func not_equal_failure_reports_equality() {
        withKnownIssue {
            expectNotEqualAny(1, 1)
        } matching: { issue in
            issue.description.contains("is equal to")
        }

        withKnownIssue {
            expectNotEqualAny(1, 1, "values must differ")
        } matching: { issue in
            issue.description.contains("values must differ")
        }
    }
}

private struct EncodablePayload: Encodable {
    let name: String
}

private struct PlainPayload {
    let name: String
}

#endif // canImport(Testing)
