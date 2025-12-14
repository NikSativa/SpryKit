#if canImport(Testing)
import Foundation
import SpryKit
import Testing

// MARK: - Test Models and Protocols

struct User: Codable, Equatable {
    let id: String
    let name: String
}

protocol UserService {
    func fetchUser(id: String) -> User
    var currentUser: User? { get set }
}

final class UserViewModel {
    private let userService: UserService
    var currentUser: User?

    init(userService: UserService) {
        self.userService = userService
    }

    func fetchUser(id: String) {
        currentUser = userService.fetchUser(id: id)
    }
}

// MARK: - Fake Implementations

final class FakeUserService: UserService, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case none
    }

    enum Function: String, StringRepresentable {
        case currentUser
        case fetchUser = "fetchUser(id:)"
    }

    var currentUser: User? {
        get { return stubbedValue() }
        set { recordCall(arguments: newValue) }
    }

    func fetchUser(id: String) -> User {
        return spryify(arguments: id)
    }
}

protocol Service {
    func doSomething() -> String
    func doSomething(with arg: String) -> String
}

final class FakeService: Service, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case none
    }

    enum Function: String, StringRepresentable {
        case doSomething = "doSomething()"
        case doSomethingWith = "doSomething(with:)"
        case method = "method()"
    }

    func doSomething() -> String {
        return spryify()
    }

    func doSomething(with arg: String) -> String {
        return spryify(arguments: arg)
    }

    func method() {
        recordCall()
    }
}

// MARK: - README Examples Tests

@Suite("README Examples Tests", .serialized)
final class READMEExamplesTests {
    // MARK: - Quick Start Examples

    @Test("Quick Start - Swift Testing example")
    func quickStart_swiftTesting() {
        let fakeUserService = FakeUserService()
        let sut = UserViewModel(userService: fakeUserService)

        // Given
        let expectedUser = User(id: "1", name: "John")
        fakeUserService.stub(.fetchUser).with("1").andReturn(expectedUser)

        // When
        sut.fetchUser(id: "1")

        // Then
        expectHaveReceived(fakeUserService, .fetchUser)
        #expect(sut.currentUser == expectedUser)
    }

    // MARK: - Spying Examples

    @Test("Spying - Verify method was called")
    func spying_verifyMethodCalled() {
        let fakeService = FakeService()
        fakeService.method()

        expectHaveReceived(fakeService, .method)
    }

    @Test("Spying - Verify with specific arguments")
    func spying_verifyWithArguments() {
        let fakeService = FakeService()
        fakeService.stub(.doSomethingWith).andReturn("value")
        _ = fakeService.doSomething(with: "expected argument")

        expectHaveReceived(fakeService, .doSomethingWith, with: "expected argument")
    }

    @Test("Spying - Verify call count")
    func spying_verifyCallCount() {
        let fakeService = FakeService()
        fakeService.method()
        fakeService.method()

        expectHaveReceived(fakeService, .method, countSpecifier: .exactly(2))
    }

    // MARK: - Stubbing Examples

    @Test("Stubbing - Simple return value")
    func stubbing_simpleReturnValue() {
        let fakeService = FakeService()
        fakeService.stub(.doSomething).andReturn("test value")

        let result = fakeService.doSomething()
        #expect(result == "test value")
    }

    @Test("Stubbing - Conditional return based on arguments")
    func stubbing_conditionalReturn() {
        let fakeService = FakeService()
        fakeService.stub(.doSomethingWith)
            .with("specific arg")
            .andReturn("special value")

        let result = fakeService.doSomething(with: "specific arg")
        #expect(result == "special value")
    }

    @Test("Stubbing - Custom implementation")
    func stubbing_customImplementation() {
        let fakeService = FakeService()
        fakeService.stub(.doSomethingWith).andDo { arguments in
            let arg = arguments[0] as! String
            return arg.uppercased()
        }

        let result = fakeService.doSomething(with: "test")
        #expect(result == "TEST")
    }

    // MARK: - Argument Capturing Examples

    @Test("Argument Capturing - Capture argument")
    func argumentCapturing_captureArgument() {
        let fakeService = FakeService()
        let captor = Argument.captor()
        fakeService.stub(.doSomethingWith).with(captor).andReturn("value")

        _ = fakeService.doSomething(with: "expected value")

        let capturedArg = captor.getValue(as: String.self)
        #expect(capturedArg == "expected value")
    }

    // MARK: - Argument Validation Examples

    @Test("Argument Validation - Custom validation")
    func argumentValidation_customValidation() {
        let fakeService = FakeService()
        let customValidation = Argument.validator { actualArgument -> Bool in
            guard let string = actualArgument as? String else {
                return false
            }

            return string.hasPrefix("test")
        }

        fakeService.stub(.doSomethingWith)
            .with(customValidation)
            .andReturn("validated")

        let result = fakeService.doSomething(with: "test123")
        #expect(result == "validated")
    }

    // MARK: - Diff API Examples

    @Test("Diff API - diffLines")
    func diffAPI_diffLines() {
        let diff = Spry.diffLines("line1\nline2", "line1\nline3")
        #expect(diff == """
          line1
        − line2
        + line3
        """)
    }

    @Test("Diff API - diffEncodable")
    func diffAPI_diffEncodable() {
        struct TestUser: Encodable {
            let id: Int
            let name: String
        }

        let user1 = TestUser(id: 1, name: "Alice")
        let user2 = TestUser(id: 2, name: "Bob")
        let diff = Spry.diffEncodable(user1, user2)
        #expect(!diff.isEmpty)
    }

    @Test("Diff API - diffMirror")
    func diffAPI_diffMirror() {
        struct TestUser {
            let id: Int
            let name: String
        }

        let user1 = TestUser(id: 1, name: "Alice")
        let user2 = TestUser(id: 2, name: "Bob")
        let diff = Spry.diffMirror(user1, user2)
        #expect(!diff.isEmpty)
    }

    // MARK: - expectEqualAny Examples

    @Test("expectEqualAny - Compare structs")
    func expectEqualAny_compareStructs() {
        struct TestUser {
            let name: String
            let age: Int
        }

        expectEqualAny(TestUser(name: "John", age: 30), TestUser(name: "John", age: 30))
        expectNotEqualAny(TestUser(name: "Bob", age: 20), TestUser(name: "John", age: 30))
    }

    // MARK: - expectThrowsAssertion Examples

    @Test("expectThrowsAssertion - Catch assertion failure")
    func expectThrowsAssertion_catchAssertion() {
        expectThrowsAssertion {
            preconditionFailure("Should fail")
        }
    }

    // MARK: - expectThrows / expectNoThrow Examples

    @Test("expectThrows - Catch error")
    func expectThrows_catchError() {
        enum TestError: Error, Equatable {
            case one
            case two
        }

        func throwError() throws {
            throw TestError.one
        }

        func notThrowError() throws {
            // nothing
        }

        expectThrows(TestError.one) {
            try throwError()
        }

        expectNoThrow {
            try notThrowError()
        }
    }

    // MARK: - expectEqualError Examples

    @Test("expectEqualError - Compare errors")
    func expectEqualError_compareErrors() {
        enum TestError: Error, Equatable {
            case one
            case two
        }

        // Direct comparison
        expectEqualError(TestError.one, TestError.one)
        expectNotEqualError(TestError.one, TestError.two)

        // With closure that returns error
        func returnError() throws -> TestError? {
            return TestError.one
        }

        func returnDifferentError() throws -> TestError? {
            return TestError.two
        }

        expectEqualError(TestError.one) {
            try returnError()
        }

        expectNotEqualError(TestError.one) {
            try returnDifferentError()
        }
    }

    // MARK: - Migration Example

    @Test("Migration - Swift Testing example")
    func migration_swiftTesting() {
        let fakeService = FakeService()
        fakeService.method()

        expectHaveReceived(fakeService, .method)
    }
}

#endif // canImport(Testing)
