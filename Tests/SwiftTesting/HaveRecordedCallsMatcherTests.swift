#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("HaveRecordedCallsMatcher Tests", .serialized)
final class HaveRecordedCallsMatcherTests {
    @Test("At least one call has been made")
    func at_least_one_call_has_been_made() {
        SpyableTestHelper.resetCalls()

        let subject: SpyableTestHelper = .init()

        expectHaveNoRecordedCalls(subject)
        expectHaveNoRecordedCalls(SpyableTestHelper.self)

        subject.doStuff()
        expectHaveRecordedCalls(subject)

        SpyableTestHelper.doClassStuff()
        expectHaveRecordedCalls(SpyableTestHelper.self)

        subject.resetCalls()
        expectHaveNoRecordedCalls(subject)

        SpyableTestHelper.resetCalls()
        expectHaveNoRecordedCalls(SpyableTestHelper.self)
    }
}

private final class SpyableTestHelper: Spyable {
    enum ClassFunction: String, StringRepresentable {
        case doStuff = "doClassStuff()"
    }

    static func doClassStuff() {
        recordCall()
    }

    enum Function: String, StringRepresentable {
        case doStuff = "doStuff()"
    }

    func doStuff() {
        recordCall()
    }
}
#endif // canImport(Testing)
