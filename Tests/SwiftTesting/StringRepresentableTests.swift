#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("StringRepresentable Tests", .serialized)
struct StringRepresentableTests {
    @Test("An exact signature resolves directly")
    func an_exact_signature_resolves_directly() {
        let subject = Signatures(functionName: "plain()", type: Self.self, file: #file, line: #line)

        #expect(subject == .plain)
    }

    @Test("A single unnamed argument suffix is dropped when the case has none")
    func a_single_unnamed_argument_suffix_is_dropped_when_the_case_has_none() {
        let subject = Signatures(functionName: "bare(_:)", type: Self.self, file: #file, line: #line)

        #expect(subject == .bare)
    }

    @Test("A single unnamed argument suffix is added when the case has one")
    func a_single_unnamed_argument_suffix_is_added_when_the_case_has_one() {
        let subject = Signatures(functionName: "withUnnamed", type: Self.self, file: #file, line: #line)

        #expect(subject == .withUnnamed)
    }

    @Test("An unknown signature traps")
    func an_unknown_signature_traps() {
        expectThrowsAssertion {
            _ = Signatures(functionName: "missing()", type: Self.self, file: #file, line: #line)
        }

        expectThrowsAssertion {
            _ = Signatures(functionName: "plain(other:)", type: Self.self, file: #file, line: #line)
        }
    }

    @Test("Raw values round trip")
    func raw_values_round_trip() {
        #expect(Signatures.plain.rawValue == "plain()")
        #expect(Signatures(rawValue: "plain()") == .plain)
        #expect(Signatures(rawValue: "nope") == nil)
    }
}

private enum Signatures: String, StringRepresentable {
    case plain = "plain()"
    case withUnnamed = "withUnnamed(_:)"
    case bare
}
#endif // canImport(Testing)
