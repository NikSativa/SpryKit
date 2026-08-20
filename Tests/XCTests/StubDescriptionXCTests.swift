import Foundation
import XCTest
@testable import SpryKit

final class StubDescriptionXCTests: XCTestCase {
    private let subject = StubDescriptionTestHelper()

    override func tearDown() {
        super.tearDown()
        subject.resetCallsAndStubs()
    }

    func test_andDoVoid_runs_the_closure_and_returns_void() {
        let recorder = ArgumentRecorder()
        subject.stub(.notifyWithValue).andDoVoid { arguments in
            recorder.record(arguments.first as? Int)
        }

        subject.notify(value: 7)

        XCTAssertEqual(recorder.values, [7])
    }

    func test_a_stub_describes_its_function_arguments_and_outcome() {
        subject.stub(.notifyWithValue).with(7).andReturn()

        let stub = subject._stubsDictionary.values[0]

        XCTAssertEqual(stub.description, stub.debugDescription)
        XCTAssertTrue(stub.description.contains("Stub(function: <notify(value:)>"))
        XCTAssertTrue(stub.description.contains("args: <<7>>"))
        XCTAssertTrue(stub.description.contains("returnValue: <andReturn"))
        XCTAssertEqual(stub.friendlyDescription, "notify(value:) with <7>")
    }

    func test_a_stub_without_arguments_describes_only_its_function() {
        subject.stub(.notifyWithValue).andReturn()

        let stub = subject._stubsDictionary.values[0]

        XCTAssertEqual(stub.friendlyDescription, "notify(value:)")
        XCTAssertTrue(stub.description.contains("args: <>"))
    }

    func test_an_incomplete_stub_describes_a_nil_outcome() {
        _ = subject.stub(.notifyWithValue).with(Argument.nil)

        let stub = subject._stubsDictionary.values[0]

        XCTAssertTrue(stub.description.contains("returnValue: <nil>"))
        XCTAssertEqual(stub.friendlyDescription, "notify(value:) with <Argument.nil>")
    }

    func test_a_recorded_call_describes_its_function_and_arguments() {
        subject.stub(.notifyWithValue).andReturn()
        subject.notify(value: 7)

        let call = subject.didCall(.notifyWithValue)

        XCTAssertEqual(call.description, call.debugDescription)
        XCTAssertTrue(call.description.contains("RecordedCall(function: <notify(value:)>"))
        XCTAssertTrue(call.description.contains("arguments: <<Optional(7)>>"))
        XCTAssertEqual(call.friendlyDescription, "notify(value:) with <7>")
    }

    func test_a_call_without_arguments_describes_only_its_function() {
        subject.stub(.ping).andReturn()
        subject.ping()

        XCTAssertEqual(subject.didCall(.ping).friendlyDescription, "ping()")
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
