#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Spryable Effects Tests", .serialized)
final class SpryableEffectsTests {
    private let subject: SpryableEffectsTestClass = .init()

    deinit {
        SpryableEffectsTestClass.resetCallsAndStubs()
    }

    @Test("Throwing function returns the stubbed value")
    func throwing_function_returns_the_stubbed_value() throws {
        subject.stub(.loadAString).andReturn("loaded")

        #expect(try subject.loadAString() == "loaded")
        #expect(subject.didCall(.loadAString).isSuccess)
    }

    @Test("Throwing function delivers the stubbed error")
    func throwing_function_delivers_the_stubbed_error() {
        subject.stub(.loadAString).andThrow(SpryableTestError.notFound)

        #expect(throws: SpryableTestError.notFound) {
            try subject.loadAString()
        }
    }

    @Test("Throwing property delivers the stubbed error")
    func throwing_property_delivers_the_stubbed_error() {
        subject.stub(.throwingName).andThrow(SpryableTestError.notFound)

        #expect(throws: SpryableTestError.notFound) {
            try subject.throwingName
        }
    }

    @Test("Rethrowing function forwards the real closure")
    func rethrowing_function_forwards_the_real_closure() throws {
        subject.stub(.rethrowingWithExecute).andDo { arguments in
            let work = arguments[0] as! () throws -> Int
            return try work()
        }

        #expect(try subject.rethrowing(execute: { try Self.throwingWork() }) == 42)
    }

    @Test("Rethrowing function cannot deliver an error")
    func rethrowing_function_cannot_deliver_an_error() {
        subject.stub(.rethrowingWithExecute).andThrow(SpryableTestError.notFound)

        expectThrowsAssertion { [subject] in
            try subject.rethrowing(execute: { try Self.throwingWork() })
        }
    }

    @Test("Closure recorded as an argument")
    func closure_recorded_as_an_argument() {
        subject.stub(.observeWithChanges).andReturn()
        subject.observe(changes: { _ in })

        #expect(subject.didCall(.observeWithChanges, withArguments: [Argument.closure]).isSuccess)
    }

    @Test("Class scoped function uses ClassFunction")
    func class_scoped_function_uses_ClassFunction() {
        SpryableEffectsTestClass.stub(.classScopedWithSome).with(1).andReturn("ok")

        #expect(SpryableEffectsTestClass.classScoped(some: 1) == "ok")
        #expect(SpryableEffectsTestClass.didCall(.classScopedWithSome, withArguments: [1]).isSuccess)
        #expect(!subject.haveRecordedCalls)
    }
    private static func throwingWork() throws -> Int {
        return 42
    }
}
#endif // canImport(Testing)
