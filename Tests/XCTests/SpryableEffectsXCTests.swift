import Foundation
import SpryKit
import XCTest

final class SpryableEffectsXCTests: XCTestCase {
    private let subject: SpryableEffectsTestClass = .init()

    override func tearDown() {
        super.tearDown()
        subject.resetCallsAndStubs()
        SpryableEffectsTestClass.resetCallsAndStubs()
    }

    func test_throwing_function_returns_the_stubbed_value() throws {
        subject.stub(.loadAString).andReturn("loaded")

        XCTAssertEqual(try subject.loadAString(), "loaded")
        XCTAssertHaveReceived(subject, .loadAString)
    }

    func test_throwing_function_delivers_the_stubbed_error() {
        subject.stub(.loadAString).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsError(try subject.loadAString(), SpryableTestError.notFound)
    }

    func test_throwing_property_delivers_the_stubbed_error() {
        subject.stub(.throwingName).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsError(try subject.throwingName, SpryableTestError.notFound)
    }

    func test_rethrowing_function_forwards_the_real_closure() throws {
        subject.stub(.rethrowingWithExecute).andDo { arguments in
            let work = arguments[0] as! () throws -> Int
            return try work()
        }

        XCTAssertEqual(try subject.rethrowing(execute: { try Self.throwingWork() }), 42)
    }

    func test_rethrowing_function_cannot_deliver_an_error() {
        subject.stub(.rethrowingWithExecute).andThrow(SpryableTestError.notFound)

        XCTAssertThrowsAssertion {
            try self.subject.rethrowing(execute: { try Self.throwingWork() })
        }
    }

    func test_closure_recorded_as_an_argument() {
        subject.stub(.observeWithChanges).andReturn()
        subject.observe(changes: { _ in })

        XCTAssertHaveReceived(subject, .observeWithChanges, with: Argument.closure)
    }

    func test_class_scoped_function_uses_ClassFunction() {
        SpryableEffectsTestClass.stub(.classScopedWithSome).with(1).andReturn("ok")

        XCTAssertEqual(SpryableEffectsTestClass.classScoped(some: 1), "ok")
        XCTAssertHaveReceived(SpryableEffectsTestClass.self, .classScopedWithSome, with: 1)
        XCTAssertHaveNoRecordedCalls(subject)
    }
    private static func throwingWork() throws -> Int {
        return 42
    }
}
