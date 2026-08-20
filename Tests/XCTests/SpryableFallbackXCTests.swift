import Foundation
import SpryKit
import XCTest

final class SpryableFallbackXCTests: XCTestCase {
    private let subject = SpryableFallbackTestHelper()

    override func tearDown() {
        super.tearDown()
        subject.resetCallsAndStubs()
        SpryableFallbackTestHelper.resetCallsAndStubs()
    }

    func test_a_stubbed_value_wins_over_the_fallback() throws {
        subject.stub(.value).andReturn("stubbed")
        subject.stub(.loadWithKey).with("key").andReturn("stubbed throws")

        XCTAssertEqual(subject.value(), "stubbed")
        XCTAssertEqual(try subject.load(key: "key"), "stubbed throws")
    }

    func test_the_fallback_is_returned_when_nothing_is_stubbed() throws {
        XCTAssertEqual(subject.value(), "fallback")
        XCTAssertEqual(try subject.load(key: "key"), "fallback throws")
    }

    func test_the_fallback_is_returned_when_the_stub_does_not_match() throws {
        subject.stub(.loadWithKey).with("other").andReturn("stubbed throws")

        XCTAssertEqual(try subject.load(key: "key"), "fallback throws")
    }

    func test_a_fallback_call_is_still_recorded() {
        _ = subject.value()

        XCTAssertHaveReceived(subject, .value)
    }

    func test_a_throwing_fallback_still_delivers_a_stubbed_error() {
        subject.stub(.loadWithKey).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsError(try subject.load(key: "key"), SpryableTestError.notFound)
    }

    func test_class_fallbacks_behave_the_same() throws {
        XCTAssertEqual(SpryableFallbackTestHelper.classValue(), "class fallback")
        XCTAssertEqual(try SpryableFallbackTestHelper.classLoad(key: "key"), "class fallback throws")
        XCTAssertHaveReceived(SpryableFallbackTestHelper.self, .classValue)

        SpryableFallbackTestHelper.stub(.classValue).andReturn("class stubbed")
        SpryableFallbackTestHelper.stub(.classLoadWithKey).andReturn("class stubbed throws")

        XCTAssertEqual(SpryableFallbackTestHelper.classValue(), "class stubbed")
        XCTAssertEqual(try SpryableFallbackTestHelper.classLoad(key: "key"), "class stubbed throws")
    }

    func test_resetting_clears_both_calls_and_stubs() {
        subject.stub(.value).andReturn("stubbed")
        _ = subject.value()
        XCTAssertHaveRecordedCalls(subject)

        subject.resetCallsAndStubs()

        XCTAssertHaveNoRecordedCalls(subject)
        XCTAssertEqual(subject.recordedCallsCount, 0)
        XCTAssertEqual(subject.value(), "fallback")
    }

    func test_andThrow_on_a_non_throwing_fallback_function_traps() {
        subject.stub(.value).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsAssertion {
            _ = self.subject.value()
        }
    }

    func test_andThrow_on_a_non_throwing_class_function_traps() {
        SpryableFallbackTestHelper.stub(.classValue).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsAssertion {
            _ = SpryableFallbackTestHelper.classValue()
        }
    }
}

private final class SpryableFallbackTestHelper: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case classValue = "classValue()"
        case classLoadWithKey = "classLoad(key:)"
    }

    enum Function: String, StringRepresentable {
        case value = "value()"
        case loadWithKey = "load(key:)"
    }

    func value() -> String {
        return spryify(fallbackValue: "fallback")
    }

    func load(key: String) throws -> String {
        return try spryifyThrows(arguments: key, fallbackValue: "fallback throws")
    }

    static func classValue() -> String {
        return spryify(fallbackValue: "class fallback")
    }

    static func classLoad(key: String) throws -> String {
        return try spryifyThrows(arguments: key, fallbackValue: "class fallback throws")
    }
}
