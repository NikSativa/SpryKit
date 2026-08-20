#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectHaveRecordedCalls Tests", .serialized)
final class ExpectHaveRecordedCallsTests {
    deinit {
        SpyableTestHelper.resetCalls()
    }

    @Test("Have recorded calls")
    func haveRecordedCalls() {
        let subject: SpyableTestHelper = .init()
        expectHaveNoRecordedCalls(subject)
        subject.doStuff()
        expectHaveRecordedCalls(subject)

        expectHaveNoRecordedCalls(SpyableTestHelper.self)
        SpyableTestHelper.doClassStuff()
        expectHaveRecordedCalls(SpyableTestHelper.self)
    }

    @Test("Failures are reported")
    func failures_are_reported() {
        let subject = SpyableTestHelper()

        withKnownIssue {
            expectHaveRecordedCalls(subject)
        } matching: { issue in
            issue.description.contains("have recorded 0 calls")
        }

        subject.doStuff()

        withKnownIssue {
            expectHaveNoRecordedCalls(subject)
        } matching: { issue in
            issue.description.contains("have recorded 1 call")
        }

        withKnownIssue {
            expectHaveRecordedCalls(SpyableTestHelper.self)
        } matching: { issue in
            issue.description.contains("have recorded 0 calls")
        }

        SpyableTestHelper.doClassStuff()

        withKnownIssue {
            expectHaveNoRecordedCalls(SpyableTestHelper.self)
        } matching: { issue in
            issue.description.contains("have recorded 1 call")
        }

        expectHaveRecordedCalls(subject, "custom")
        expectHaveNoRecordedCalls(SpyableTestHelper(), "custom")
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
