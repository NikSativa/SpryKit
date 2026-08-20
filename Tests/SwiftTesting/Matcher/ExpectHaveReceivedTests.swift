#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectHaveReceived Tests", .serialized)
final class ExpectHaveReceivedTests {
    let actualArgument = "correct arg"
    private var subject: SpyableTestHelper = .init()

    deinit {
        SpyableTestHelper.resetCalls()
    }

    @Test("Have received success result")
    func have_received_success_result() {
        // instance
        subject.doStuffWith(string: actualArgument)

        expectHaveReceived(subject, .doStuffWithString)
        expectHaveReceived(subject, .doStuffWithString, with: actualArgument)
        expectHaveReceived(subject, .doStuffWithString, countSpecifier: .exactly(1))
        expectHaveReceived(subject, .doStuffWithString, with: actualArgument, countSpecifier: .exactly(1))

        expectHaveNotReceived(subject, .doStuff)
        expectHaveNotReceived(subject, .doStuffWithInts)

        // class
        SpyableTestHelper.doClassStuffWith(string: actualArgument)
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString)
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: actualArgument)
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, countSpecifier: .exactly(1))
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: actualArgument, countSpecifier: .exactly(1))

        expectHaveNotReceived(SpyableTestHelper.self, .doStuff)
    }

    @Test("Have received")
    func haveReceived() {
        subject.doStuff()

        expectHaveReceived(subject, .doStuff)
        expectHaveReceived(subject, .doStuff, countSpecifier: .exactly(1))

        expectHaveNotReceived(subject, .doStuffWithString)
        expectHaveNotReceived(subject, .doStuffWithInts)
    }

    @Test("Have received with argument")
    func haveReceivedWithArgument() {
        subject.doStuffWith(string: actualArgument)

        expectHaveReceived(subject, .doStuffWithString)
        expectHaveReceived(subject, .doStuffWithString, with: actualArgument)
        expectHaveReceived(subject, .doStuffWithString, countSpecifier: .exactly(1))
        expectHaveReceived(subject, .doStuffWithString, with: actualArgument, countSpecifier: .exactly(1))

        expectHaveNotReceived(subject, .doStuff)
        expectHaveNotReceived(subject, .doStuffWithInts)
    }

    @Test("Have received with 2 arguments")
    func haveReceivedWith2Arguments() {
        subject.doStuffWith(int1: 1, int2: 2)

        expectHaveReceived(subject, .doStuffWithInts)
        expectHaveReceived(subject, .doStuffWithInts, with: 1, 2)
        expectHaveReceived(subject, .doStuffWithInts, countSpecifier: .exactly(1))
        expectHaveReceived(subject, .doStuffWithInts, with: 1, 2, countSpecifier: .exactly(1))

        expectHaveNotReceived(subject, .doStuff)
        expectHaveNotReceived(subject, .doStuffWithString)
    }

    @Test("Nil spyable explains itself")
    func nil_spyable_explains_itself() {
        let missing: SpyableTestHelper? = nil

        withKnownIssue {
            expectHaveReceived(missing, .doStuff)
        } matching: { issue in
            issue.description.contains("but spyable is nil")
        }

        withKnownIssue {
            expectHaveNotReceived(missing, .doStuff)
        } matching: { issue in
            issue.description.contains("but spyable is nil")
        }
    }

    @Test("Count specifiers shape the report")
    func count_specifiers_shape_the_report() {
        let subject = SpyableTestHelper()
        subject.doStuff()
        subject.doStuff()

        expectHaveReceived(subject, .doStuff, countSpecifier: .exactly(2))
        expectHaveReceived(subject, .doStuff, countSpecifier: .atLeast(2))
        expectHaveReceived(subject, .doStuff, countSpecifier: .atMost(2))
        expectHaveNotReceived(subject, .doStuff, countSpecifier: .exactly(3))

        withKnownIssue {
            expectHaveReceived(subject, .doStuff, countSpecifier: .exactly(3))
        } matching: { issue in
            issue.description.contains("exactly 3 times")
        }

        withKnownIssue {
            expectHaveReceived(subject, .doStuff, countSpecifier: .atLeast(3))
        } matching: { issue in
            issue.description.contains("at least 3 times")
        }

        withKnownIssue {
            expectHaveReceived(subject, .doStuff, countSpecifier: .atMost(1))
        } matching: { issue in
            issue.description.contains("at most 1 time")
        }
    }

    @Test("Nil spyable reports each count specifier")
    func nil_spyable_reports_each_count_specifier() {
        let missing: SpyableTestHelper? = nil

        withKnownIssue {
            expectHaveReceived(missing, .doStuffWithString, with: "x", countSpecifier: .exactly(1))
        } matching: { issue in
            issue.description.contains("with arguments") && issue.description.contains("'count' times")
        }

        withKnownIssue {
            expectHaveReceived(missing, .doStuff, countSpecifier: .atLeast(2))
        } matching: { issue in
            issue.description.contains("at least 'count' times")
        }

        withKnownIssue {
            expectHaveReceived(missing, .doStuff, countSpecifier: .atMost(2))
        } matching: { issue in
            issue.description.contains("at most 'count' times")
        }

        withKnownIssue {
            expectHaveNotReceived(missing, .doStuffWithString, with: "x")
        }

        withKnownIssue {
            expectHaveReceived(SpyableTestHelper.Type?.none, .doStuff)
        }

        withKnownIssue {
            expectHaveNotReceived(SpyableTestHelper.Type?.none, .doStuff, with: "x")
        }
    }

    @Test("A failed expectation returns false")
    func a_failed_expectation_returns_false() {
        let subject = SpyableTestHelper()

        withKnownIssue {
            #expect(!expectHaveReceived(subject, .doStuff))
        }

        subject.doStuff()

        withKnownIssue {
            #expect(!expectHaveNotReceived(subject, .doStuff))
        }
    }
}

private final class SpyableTestHelper: Spyable {
    enum ClassFunction: String, StringRepresentable {
        case doStuff = "doClassStuff()"
        case doStuffWithString = "doClassStuffWith(string:)"
    }

    static func doClassStuff() {
        recordCall()
    }

    static func doClassStuffWith(string: String) {
        recordCall(arguments: string)
    }

    enum Function: String, StringRepresentable {
        case doStuff = "doStuff()"
        case doStuffWithString = "doStuffWith(string:)"
        case doStuffWithInts = "doStuffWith(int1:int2:)"
    }

    func doStuff() {
        recordCall()
    }

    func doStuffWith(string: String) {
        recordCall(arguments: string)
    }

    func doStuffWith(int1: Int, int2: Int) {
        recordCall(arguments: int1, int2)
    }
}
#endif // canImport(Testing)
