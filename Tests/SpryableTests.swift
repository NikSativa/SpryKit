import Foundation
import SpryKit
import XCTest

final class SpryableTests: XCTestCase {
    let subject: SpryableTestClass = .init()

    override func tearDown() {
        super.tearDown()
        subject.resetCallsAndStubs()
        SpryableTestClass.resetCallsAndStubs()
    }

    func test_recording_calls_instance_with_arguments() {
        subject.stub(.getAStringWithString).andReturn("out")
        let actual = subject.getAString(string: "in")
        XCTAssertTrue(subject.didCall(.getAStringWithString).success)
        XCTAssertEqual(actual, "out")
    }

    func test_recording_calls_instance() {
        subject.stub(.getAString).andReturn("out")
        let actual = subject.getAString()
        XCTAssertTrue(subject.didCall(.getAString).success)
        XCTAssertEqual(actual, "out")
    }

    func test_recording_calls_class() {
        SpryableTestClass.stub(.getAStaticString).andReturn("out")
        let actual = SpryableTestClass.getAStaticString()
        XCTAssertTrue(SpryableTestClass.didCall(.getAStaticString).success)
        XCTAssertEqual(actual, "out")
    }

    func test_stubbing_functions_instance() {
        let expectedString = "stubbed string"
        subject.stub(.getAString).andReturn(expectedString)
        XCTAssertEqual(subject.getAString(), expectedString)
    }

    func test_stubbing_functions_class() {
        let expectedString = "stubbed string"
        SpryableTestClass.stub(.getAStaticString).andReturn(expectedString)
        XCTAssertEqual(SpryableTestClass.getAStaticString(), expectedString)
    }

    func test_reseting_calls_and_stubs_instance() {
        subject.stub(.getAString).andReturn("")
        _ = subject.getAString()
        subject.resetCallsAndStubs()

        XCTAssertFalse(subject.didCall(.getAString).success)

        #if (os(macOS) || os(iOS) || os(visionOS)) && (arch(x86_64) || arch(arm64))
        XCTAssertThrowsAssertion {
            _ = self.subject.getAString()
        }
        #endif
    }

    func test_reseting_calls_and_stubs_class() {
        SpryableTestClass.stub(.getAStaticString).andReturn("")
        _ = SpryableTestClass.getAStaticString()
        SpryableTestClass.resetCallsAndStubs()

        XCTAssertFalse(SpryableTestClass.didCall(.getAStaticString).success)

        #if (os(macOS) || os(iOS) || os(visionOS)) && (arch(x86_64) || arch(arm64))
        XCTAssertThrowsAssertion {
            _ = SpryableTestClass.getAStaticString()
        }
        #endif
    }
}
