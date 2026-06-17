import Foundation
import SpryKit
import XCTest

private final class MetatypeResolverFake: Spryable, @unchecked Sendable {
    enum ClassFunction: String, StringRepresentable {
        case _unknown_ = "'enum' must have at least one 'case'"
    }

    enum Function: String, StringRepresentable {
        case optionalResolveWithType_Named_With = "optionalResolve(type:named:with:)"
    }

    func optionalResolve<T>(type: T.Type, named: String?, with arguments: Int) -> T? {
        return spryify(arguments: type, named, arguments)
    }
}

private final class ServiceClass {}
private protocol ServiceProtocol {}
private final class ServiceImpl: ServiceProtocol {}

final class MetatypeStubXCTests: XCTestCase {
    func testClassMetatypeMatching() {
        let fake = MetatypeResolverFake()
        let svc = ServiceClass()
        fake.stub(.optionalResolveWithType_Named_With)
            .with(ServiceClass.self, Argument.anything, Argument.anything)
            .andReturn(svc)

        let resolved: ServiceClass? = fake.optionalResolve(type: ServiceClass.self, named: nil, with: 0)
        XCTAssertTrue(resolved === svc)
    }

    func testProtocolMetatypeMatching() {
        let fake = MetatypeResolverFake()
        let svc: ServiceProtocol = ServiceImpl()
        fake.stub(.optionalResolveWithType_Named_With)
            .with(ServiceProtocol.self, Argument.anything, Argument.anything)
            .andReturn(svc)

        let resolved: ServiceProtocol? = fake.optionalResolve(type: ServiceProtocol.self, named: nil, with: 0)
        XCTAssertNotNil(resolved)
    }

    func testIsAnyEqualOnMetatypes() {
        XCTAssertTrue(isAnyEqual(ServiceClass.self, ServiceClass.self))
        XCTAssertTrue(isAnyEqual(ServiceProtocol.self, ServiceProtocol.self))
        XCTAssertFalse(isAnyEqual(ServiceClass.self, ServiceImpl.self))
    }
}
