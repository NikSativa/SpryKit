#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Stubbable Only Tests", .serialized)
final class StubbableOnlyTests {
    private let subject = StubbableOnlyTestHelper()

    deinit {
        StubbableOnlyTestHelper.resetStubs()
    }

    @Test("A stub without spying returns the stubbed value")
    func a_stub_without_spying_returns_the_stubbed_value() throws {
        subject.stub(.value).andReturn("stubbed")
        subject.stub(.loadWithKey).with("key").andReturn("loaded")

        #expect(subject.value() == "stubbed")
        #expect(try subject.load(key: "key") == "loaded")
    }

    @Test("A stub without spying falls back")
    func a_stub_without_spying_falls_back() throws {
        #expect(subject.fallbackValue() == "fallback")
        #expect(try subject.fallbackLoad(key: "key") == "fallback throws")
    }

    @Test("Class stubs without spying")
    func class_stubs_without_spying() throws {
        StubbableOnlyTestHelper.stub(.classValue).andReturn("class stubbed")
        StubbableOnlyTestHelper.stub(.classLoadWithKey).andReturn("class loaded")

        #expect(StubbableOnlyTestHelper.classValue() == "class stubbed")
        #expect(try StubbableOnlyTestHelper.classLoad(key: "key") == "class loaded")
        #expect(StubbableOnlyTestHelper.classFallbackValue() == "class fallback")
    }

    @Test("andThrow on a non-throwing function traps")
    func andThrow_on_a_non_throwing_function_traps() {
        subject.stub(.value).andThrow(SpryableTestError.notFound)

        expectThrowsAssertion { [subject] in
            _ = subject.value()
        }
    }

    @Test("andThrow on a non-throwing class function traps")
    func andThrow_on_a_non_throwing_class_function_traps() {
        StubbableOnlyTestHelper.stub(.classValue).andThrow(SpryableTestError.notFound)

        expectThrowsAssertion {
            _ = StubbableOnlyTestHelper.classValue()
        }
    }

    @Test("A missing stub traps")
    func a_missing_stub_traps() {
        expectThrowsAssertion { [subject] in
            _ = subject.value()
        }

        expectThrowsAssertion {
            _ = StubbableOnlyTestHelper.classValue()
        }
    }

    @Test("A stub of the wrong type traps")
    func a_stub_of_the_wrong_type_traps() {
        subject.stub(.value).andReturn(42)

        expectThrowsAssertion { [subject] in
            _ = subject.value()
        }
    }
}

private final class StubbableOnlyTestHelper: Stubbable {
    enum ClassFunction: String, StringRepresentable {
        case classValue = "classValue()"
        case classLoadWithKey = "classLoad(key:)"
        case classFallbackValue = "classFallbackValue()"
    }

    enum Function: String, StringRepresentable {
        case value = "value()"
        case loadWithKey = "load(key:)"
        case fallbackValue = "fallbackValue()"
        case fallbackLoadWithKey = "fallbackLoad(key:)"
    }

    func value() -> String {
        return stubbedValue()
    }

    func load(key: String) throws -> String {
        return try stubbedValueThrows(arguments: key)
    }

    func fallbackValue() -> String {
        return stubbedValue(fallbackValue: "fallback")
    }

    func fallbackLoad(key: String) throws -> String {
        return try stubbedValueThrows(arguments: key, fallbackValue: "fallback throws")
    }

    static func classValue() -> String {
        return stubbedValue()
    }

    static func classLoad(key: String) throws -> String {
        return try stubbedValueThrows(arguments: key)
    }

    static func classFallbackValue() -> String {
        return stubbedValue(fallbackValue: "class fallback")
    }
}
#endif // canImport(Testing)
