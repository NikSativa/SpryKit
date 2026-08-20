#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Spyable Tests", .serialized)
final class SpyableTests {
    private var subject: SpyableTestHelper = .init()

    deinit {
        SpyableTestHelper.resetCalls()
    }

    @Test("Resetting calls")
    func resetting_calls() {
        subject.doStuff()
        subject.resetCalls()
        subject.doStuffWith(string: "")

        #expect(!subject.didCall(.doStuff).isSuccess)
        #expect(subject.didCall(.doStuffWithString).isSuccess)
    }

    @Test("On the class")
    func on_the_class() {
        SpyableTestHelper.resetCalls() // Ensure clean state before test
        SpyableTestHelper.doClassStuff()
        SpyableTestHelper.resetCalls()
        SpyableTestHelper.doClassStuffWith(string: "")

        #expect(!SpyableTestHelper.didCall(.doStuff).isSuccess)
        #expect(SpyableTestHelper.didCall(.doStuffWithString).isSuccess)
    }

    @Test("Set property")
    func set_property() {
        let newValue = "new value"
        subject.ivarProperty = newValue
        #expect(subject.didCall(.ivarProperty).isSuccess)
        #expect(subject.didCall(.ivarProperty, withArguments: [newValue]).isSuccess)
    }

    @Test("Call function")
    func call_function() {
        subject.doStuff()
        #expect(subject.didCall(.doStuff).isSuccess)
        #expect(!subject.didCall(.doStuffWithString).isSuccess)
    }

    @Test("Call class function no args count specifier")
    func call_class_function_no_args_count_specifier() {
        SpyableTestHelper.resetCalls() // Ensure clean state before test
        SpyableTestHelper.doClassStuff()
        SpyableTestHelper.doClassStuff()

        expectHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(1))
        expectHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(2))
        expectHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(3))

        expectHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atLeast(1))
        expectHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atLeast(2))
        expectHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atLeast(3))

        expectHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atMost(1))
        expectHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atMost(2))
        expectHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atMost(3))
    }

    @Test("Call function no args count specifier")
    func call_function_no_args_count_specifier() {
        subject.doStuff()
        subject.doStuff()

        expectHaveNotReceived(subject, .doStuff, countSpecifier: .exactly(1))
        expectHaveReceived(subject, .doStuff, countSpecifier: .exactly(2))
        expectHaveNotReceived(subject, .doStuff, countSpecifier: .exactly(3))

        expectHaveReceived(subject, .doStuff, countSpecifier: .atLeast(1))
        expectHaveReceived(subject, .doStuff, countSpecifier: .atLeast(2))
        expectHaveNotReceived(subject, .doStuff, countSpecifier: .atLeast(3))

        expectHaveNotReceived(subject, .doStuff, countSpecifier: .atMost(1))
        expectHaveReceived(subject, .doStuff, countSpecifier: .atMost(2))
        expectHaveReceived(subject, .doStuff, countSpecifier: .atMost(3))
    }

    @Test("Call function no count specifier")
    func call_function_no_count_specifier() {
        let actualString = "actual string"
        subject.doStuffWith(string: actualString)
        #expect(subject.didCall(.doStuffWithString, withArguments: [actualString]).isSuccess)
        #expect(!subject.didCall(.doStuffWithString, withArguments: ["wrong string"]).isSuccess)
    }

    @Test("Call function with args count specifier")
    func call_function_with_args_count_specifier() {
        let actualString = "correct string"
        subject.doStuffWith(string: actualString)
        subject.doStuffWith(string: "other string")
        subject.doStuffWith(string: actualString)

        expectHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .exactly(1))
        expectHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .exactly(2))
        expectHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .exactly(3))

        expectHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atLeast(1))
        expectHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atLeast(2))
        expectHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atLeast(3))

        expectHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atMost(1))
        expectHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atMost(2))
        expectHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atMost(3))
    }

    @Test("Call class function with args count specifier")
    func call_class_function_with_args_count_specifier() {
        SpyableTestHelper.resetCalls() // Ensure clean state before test
        let arg = "arg"
        SpyableTestHelper.doClassStuffWith(string: arg)
        SpyableTestHelper.doClassStuffWith(string: "other arg")
        SpyableTestHelper.doClassStuffWith(string: arg)

        expectHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .exactly(1))
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .exactly(2))
        expectHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .exactly(3))

        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atLeast(1))
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atLeast(2))
        expectHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atLeast(3))

        expectHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atMost(1))
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atMost(2))
        expectHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atMost(3))
    }

    @Test("Call class function")
    func call_class_function() {
        SpyableTestHelper.resetCalls() // Ensure clean state before test
        let actualArgument = "correct string"
        SpyableTestHelper.doClassStuffWith(string: actualArgument)
        #expect(SpyableTestHelper.didCall(.doStuffWithString).isSuccess)
        #expect(SpyableTestHelper.didCall(.doStuffWithString, withArguments: [actualArgument]).isSuccess)
        #expect(SpyableTestHelper.didCall(.doStuffWithString, countSpecifier: .exactly(1)).isSuccess)
        #expect(SpyableTestHelper.didCall(.doStuffWithString, withArguments: [actualArgument], countSpecifier: .exactly(1)).isSuccess)
        #expect(!SpyableTestHelper.didCall(.doStuff).isSuccess)
    }

    @Test("Recording a call with the wrong argument count traps")
    func recording_a_call_with_the_wrong_argument_count_traps() {
        expectThrowsAssertion { [subject] in
            subject.recordCall(functionName: "doStuffWith(int1:int2:)", arguments: 1)
        }
    }

    @Test("Optional argument member is not a wildcard")
    func optional_argument_member_is_not_a_wildcard() {
        let spy = PayloadSpyTestHelper()
        spy.send(payload: .init(id: 1, note: "actual"))

        #expect(!spy.didCall(.sendWithPayload, withArguments: [SpyablePayload(id: 1, note: nil)]).isSuccess)
        #expect(!spy.didCall(.sendWithPayload, withArguments: [SpyablePayload(id: 1, note: "other")]).isSuccess)
        #expect(spy.didCall(.sendWithPayload, withArguments: [SpyablePayload(id: 1, note: "actual")]).isSuccess)
    }

    @Test("Result descriptions")
    func result_descriptions() {
        subject.doStuff()
        let result = subject.didCall(.doStuff)
        #expect(result.description == result.debugDescription)
        #expect(!result.description.isEmpty)
    }

    @Test("Result recorded calls description")
    func result_recordedCallsDescription() {
        #expect(subject.didCall(.doStuff).friendlyDescription == "<>")

        subject.doStuff()
        #expect(subject.didCall(.doStuff).friendlyDescription == "\(SpyableTestHelper.Function.doStuff.rawValue)")

        let firstArg = 1
        let secondArg = 2

        subject.resetCalls()
        subject.doStuffWith(int1: firstArg, int2: secondArg)
        let expectedDescription = "\(SpyableTestHelper.Function.doStuffWithInts.rawValue) with <\(firstArg)>, <\(secondArg)>"
        #expect(subject.didCall(.doStuff).friendlyDescription == expectedDescription)

        subject.resetCalls()
        subject.doStuff()
        subject.doStuffWith(int1: firstArg, int2: secondArg)
        let expectedDescription2 = "\(SpyableTestHelper.Function.doStuff.rawValue); \(SpyableTestHelper.Function.doStuffWithInts.rawValue) with <\(firstArg)>, <\(secondArg)>"
        #expect(subject.didCall(.doStuff).friendlyDescription == expectedDescription2)
    }
}

private struct SpyablePayload {
    let id: Int
    let note: String?
}

private final class PayloadSpyTestHelper: Spyable {
    enum ClassFunction: String, StringRepresentable {
        case _unknown_
    }

    enum Function: String, StringRepresentable {
        case sendWithPayload = "send(payload:)"
    }

    func send(payload: SpyablePayload) {
        recordCall(arguments: payload)
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
        case ivarProperty
        case doStuff = "doStuff()"
        case doStuffWithString = "doStuffWith(string:)"
        case doStuffWithInts = "doStuffWith(int1:int2:)"
    }

    var ivarProperty: String = "" {
        didSet {
            recordCall(arguments: ivarProperty)
        }
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
