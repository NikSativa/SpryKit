#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Spryable Tests", .serialized)
final class SpryableTests {
    var subject: SpryableTestClass = .init()

    deinit {
        SpryableTestClass.resetCallsAndStubs()
    }

    @Test("Recording calls instance with arguments")
    func recording_calls_instance_with_arguments() {
        subject.stub(.getAStringWithString).andReturn("out")
        let actual = subject.getAString(string: "in")
        #expect(subject.didCall(.getAStringWithString).isSuccess)
        #expect(actual == "out")
    }

    @Test("Recording calls instance")
    func recording_calls_instance() {
        subject.stub(.getAString).andReturn("out")
        let actual = subject.getAString()
        #expect(subject.didCall(.getAString).isSuccess)
        #expect(actual == "out")
    }

    @Test("Recording calls class")
    func recording_calls_class() {
        SpryableTestClass.stub(.getAStaticString).andReturn("out")
        let actual = SpryableTestClass.getAStaticString()
        #expect(SpryableTestClass.didCall(.getAStaticString).isSuccess)
        #expect(actual == "out")
    }

    @Test("Stubbing functions instance")
    func stubbing_functions_instance() {
        let expectedString = "stubbed string"
        subject.stub(.getAString).andReturn(expectedString)
        #expect(subject.getAString() == expectedString)
    }

    @Test("Stubbing functions class")
    func stubbing_functions_class() {
        let expectedString = "stubbed string"
        SpryableTestClass.stub(.getAStaticString).andReturn(expectedString)
        #expect(SpryableTestClass.getAStaticString() == expectedString)
    }

    @Test("Resetting calls and stubs instance")
    func reseting_calls_and_stubs_instance() {
        subject.stub(.getAString).andReturn("")
        _ = subject.getAString()
        subject.resetCallsAndStubs()

        #expect(!subject.didCall(.getAString).isSuccess)

        expectThrowsAssertion { [subject] in
            _ = subject.getAString()
        }
    }

    @Test("Resetting calls and stubs class")
    func reseting_calls_and_stubs_class() {
        SpryableTestClass.stub(.getAStaticString).andReturn("")
        _ = SpryableTestClass.getAStaticString()
        SpryableTestClass.resetCallsAndStubs()

        #expect(!SpryableTestClass.didCall(.getAStaticString).isSuccess)

        expectThrowsAssertion {
            _ = SpryableTestClass.getAStaticString()
        }
    }
}
#endif // canImport(Testing)
