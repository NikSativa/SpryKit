#if canImport(Testing)
import Foundation
import Testing
@testable import SpryKit

@Suite("DidCallResult Tests", .serialized)
struct DidCallResultTests {
    @Test("Each description uses its own source")
    func each_description_uses_its_own_source() {
        let subject = DidCallResult(success: true,
                                    description: "plain",
                                    debugDescription: "debug",
                                    friendlyDescription: "friendly")

        #expect(subject.success)
        #expect(subject.description == "plain")
        #expect(subject.debugDescription == "debug")
        #expect(subject.friendlyDescription == "friendly")
    }

    @Test("Descriptions are evaluated lazily and only once")
    func descriptions_are_evaluated_lazily_and_only_once() {
        let counter = CallCounter()
        let subject = DidCallResult(success: false,
                                    description: counter.next(),
                                    debugDescription: "debug",
                                    friendlyDescription: "friendly")

        #expect(counter.count == 0)
        #expect(subject.description == "1")
        #expect(subject.description == "1")
        #expect(counter.count == 1)
    }
}

private final class CallCounter {
    private(set) var count: Int = 0

    func next() -> String {
        count += 1
        return "\(count)"
    }
}
#endif // canImport(Testing)
