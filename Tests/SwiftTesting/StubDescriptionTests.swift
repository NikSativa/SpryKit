#if canImport(Testing)
import Foundation
import Testing
@testable import SpryKit

@Suite("Stub Description Tests", .serialized)
final class StubDescriptionTests {
    private let subject = StubDescriptionTestHelper()

    deinit {
        subject.resetCallsAndStubs()
    }

    @Test("andDoVoid runs the closure and returns void")
    func andDoVoid_runs_the_closure_and_returns_void() {
        let recorder = ArgumentRecorder()
        subject.stub(.notifyWithValue).andDoVoid { arguments in
            recorder.record(arguments.first as? Int)
        }

        subject.notify(value: 7)

        #expect(recorder.values == [7])
    }

    @Test("A stub describes its function, arguments and outcome")
    func a_stub_describes_its_function_arguments_and_outcome() {
        subject.stub(.notifyWithValue).with(7).andReturn()

        let stub = subject._stubsDictionary.values[0]

        #expect(stub.description == stub.debugDescription)
        #expect(stub.description.contains("Stub(function: <notify(value:)>"))
        #expect(stub.description.contains("args: <<7>>"))
        #expect(stub.description.contains("returnValue: <andReturn"))
        #expect(stub.friendlyDescription == "notify(value:) with <7>")
    }

    @Test("A stub without arguments describes only its function")
    func a_stub_without_arguments_describes_only_its_function() {
        subject.stub(.notifyWithValue).andReturn()

        let stub = subject._stubsDictionary.values[0]

        #expect(stub.friendlyDescription == "notify(value:)")
        #expect(stub.description.contains("args: <>"))
    }

    @Test("An incomplete stub describes a nil outcome")
    func an_incomplete_stub_describes_a_nil_outcome() {
        _ = subject.stub(.notifyWithValue).with(Argument.nil)

        let stub = subject._stubsDictionary.values[0]

        #expect(stub.description.contains("returnValue: <nil>"))
        #expect(stub.friendlyDescription == "notify(value:) with <Argument.nil>")
    }

    @Test("A recorded call describes its function and arguments")
    func a_recorded_call_describes_its_function_and_arguments() {
        subject.stub(.notifyWithValue).andReturn()
        subject.notify(value: 7)

        let call = subject.didCall(.notifyWithValue)

        #expect(call.description == call.debugDescription)
        #expect(call.description.contains("RecordedCall(function: <notify(value:)>"))
        #expect(call.description.contains("arguments: <<Optional(7)>>"))
        #expect(call.friendlyDescription == "notify(value:) with <7>")
    }

    @Test("A call without arguments describes only its function")
    func a_call_without_arguments_describes_only_its_function() {
        subject.stub(.ping).andReturn()
        subject.ping()

        #expect(subject.didCall(.ping).friendlyDescription == "ping()")
    }
}

private final class ArgumentRecorder {
    private(set) var values: [Int?] = []

    func record(_ value: Int?) {
        values.append(value)
    }
}

private final class StubDescriptionTestHelper: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case _unknown_
    }

    enum Function: String, StringRepresentable {
        case notifyWithValue = "notify(value:)"
        case ping = "ping()"
    }

    func notify(value: Int) {
        return spryify(arguments: value)
    }

    func ping() {
        return spryify()
    }
}
#endif // canImport(Testing)
