#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Spryable Fallback Tests", .serialized)
final class SpryableFallbackTests {
    private let subject = SpryableFallbackTestHelper()

    deinit {
        SpryableFallbackTestHelper.resetCallsAndStubs()
    }

    @Test("A stubbed value wins over the fallback")
    func a_stubbed_value_wins_over_the_fallback() throws {
        subject.stub(.value).andReturn("stubbed")
        subject.stub(.loadWithKey).with("key").andReturn("stubbed throws")

        #expect(subject.value() == "stubbed")
        #expect(try subject.load(key: "key") == "stubbed throws")
    }

    @Test("The fallback is returned when nothing is stubbed")
    func the_fallback_is_returned_when_nothing_is_stubbed() throws {
        #expect(subject.value() == "fallback")
        #expect(try subject.load(key: "key") == "fallback throws")
    }

    @Test("The fallback is returned when the stub does not match")
    func the_fallback_is_returned_when_the_stub_does_not_match() throws {
        subject.stub(.loadWithKey).with("other").andReturn("stubbed throws")

        #expect(try subject.load(key: "key") == "fallback throws")
    }

    @Test("A fallback call is still recorded")
    func a_fallback_call_is_still_recorded() {
        _ = subject.value()

        #expect(subject.didCall(.value).isSuccess)
    }

    @Test("A throwing fallback still delivers a stubbed error")
    func a_throwing_fallback_still_delivers_a_stubbed_error() {
        subject.stub(.loadWithKey).andThrow(SpryableTestError.notFound)

        #expect(throws: SpryableTestError.notFound) {
            try subject.load(key: "key")
        }
    }

    @Test("Class fallbacks behave the same")
    func class_fallbacks_behave_the_same() throws {
        #expect(SpryableFallbackTestHelper.classValue() == "class fallback")
        #expect(try SpryableFallbackTestHelper.classLoad(key: "key") == "class fallback throws")
        #expect(SpryableFallbackTestHelper.didCall(.classValue).isSuccess)

        SpryableFallbackTestHelper.stub(.classValue).andReturn("class stubbed")
        SpryableFallbackTestHelper.stub(.classLoadWithKey).andReturn("class stubbed throws")

        #expect(SpryableFallbackTestHelper.classValue() == "class stubbed")
        #expect(try SpryableFallbackTestHelper.classLoad(key: "key") == "class stubbed throws")
    }

    @Test("Resetting clears both calls and stubs")
    func resetting_clears_both_calls_and_stubs() {
        subject.stub(.value).andReturn("stubbed")
        _ = subject.value()
        #expect(subject.haveRecordedCalls)

        subject.resetCallsAndStubs()

        #expect(!subject.haveRecordedCalls)
        #expect(subject.recordedCallsCount == 0)
        #expect(subject.value() == "fallback")
    }

    @Test("andThrow on a non-throwing fallback function traps")
    func andThrow_on_a_non_throwing_fallback_function_traps() {
        subject.stub(.value).andThrow(SpryableTestError.notFound)

        expectThrowsAssertion { [subject] in
            _ = subject.value()
        }
    }

    @Test("andThrow on a non-throwing class function traps")
    func andThrow_on_a_non_throwing_class_function_traps() {
        SpryableFallbackTestHelper.stub(.classValue).andThrow(SpryableTestError.notFound)

        expectThrowsAssertion {
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
#endif // canImport(Testing)
