import Foundation
import SpryKit
import XCTest

final class StubbableOnlyXCTests: XCTestCase {
    private let subject = StubbableOnlyTestHelper()

    override func tearDown() {
        super.tearDown()
        subject.resetStubs()
        StubbableOnlyTestHelper.resetStubs()
    }

    func test_a_stub_without_spying_returns_the_stubbed_value() throws {
        subject.stub(.value).andReturn("stubbed")
        subject.stub(.loadWithKey).with("key").andReturn("loaded")

        XCTAssertEqual(subject.value(), "stubbed")
        XCTAssertEqual(try subject.load(key: "key"), "loaded")
    }

    func test_a_stub_without_spying_falls_back() throws {
        XCTAssertEqual(subject.fallbackValue(), "fallback")
        XCTAssertEqual(try subject.fallbackLoad(key: "key"), "fallback throws")
    }

    func test_class_stubs_without_spying() throws {
        StubbableOnlyTestHelper.stub(.classValue).andReturn("class stubbed")
        StubbableOnlyTestHelper.stub(.classLoadWithKey).andReturn("class loaded")

        XCTAssertEqual(StubbableOnlyTestHelper.classValue(), "class stubbed")
        XCTAssertEqual(try StubbableOnlyTestHelper.classLoad(key: "key"), "class loaded")
        XCTAssertEqual(StubbableOnlyTestHelper.classFallbackValue(), "class fallback")
    }

    func test_andThrow_on_a_non_throwing_function_traps() {
        subject.stub(.value).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsAssertion {
            _ = self.subject.value()
        }
    }

    func test_andThrow_on_a_non_throwing_class_function_traps() {
        StubbableOnlyTestHelper.stub(.classValue).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsAssertion {
            _ = StubbableOnlyTestHelper.classValue()
        }
    }

    func test_a_missing_stub_traps() {
        XCTAssertThrowsAssertion {
            _ = self.subject.value()
        }

        XCTAssertThrowsAssertion {
            _ = StubbableOnlyTestHelper.classValue()
        }
    }

    func test_a_stub_of_the_wrong_type_traps() {
        subject.stub(.value).andReturn(42)

        XCTAssertThrowsAssertion {
            _ = self.subject.value()
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
