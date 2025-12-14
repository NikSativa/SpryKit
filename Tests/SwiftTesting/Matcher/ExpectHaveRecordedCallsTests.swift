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
