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
