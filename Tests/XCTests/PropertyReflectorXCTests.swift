import Foundation
import SpryKit
import XCTest

final class PropertyReflectorSpecXCTests: XCTestCase {
    private let subject = PropertyReflector.scan(Container<SomeGeneric>())

    // MARK: - weak types

    func test_weak_let_let() {
        let someValue: Some = subject.property(named: "lsome")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "lsomeWithProtocol")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "lprotocol")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "lgeneric")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "lgeneric")
        XCTAssertNotNil(generic)
    }

    func test_weak_let_optional() {
        let someValue: Some? = subject.property(named: "lsomeOptional")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolOptional")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolOptional")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericOptional")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "lgenericOptional")
        XCTAssertNotNil(generic)
    }

    func test_weak_let_optional_be_nil() {
        let someValue: Some? = subject.property(named: "lsomeOptionalNil")
        XCTAssertNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolOptionalNil")
        XCTAssertNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolOptionalNil")
        XCTAssertNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericOptionalNil")
        XCTAssertNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "lgenericOptionalNil")
        XCTAssertNil(generic)
    }

    func test_weak_let_implicitly_optional() {
        let someValue: Some? = subject.property(named: "lsomeImplicitly")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolImplicitly")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolImplicitly")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericImplicitly")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "lgenericImplicitly")
        XCTAssertNotNil(generic)
    }

    func test_weak_let_implicitly_optional_be_nil() {
        let someValue: Some? = subject.property(named: "lsomeImplicitlyNil")
        XCTAssertNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolImplicitlyNil")
        XCTAssertNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolImplicitlyNil")
        XCTAssertNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericImplicitlyNil")
        XCTAssertNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "lgenericImplicitlyNil")
        XCTAssertNil(generic)
    }

    func test_weak_var_let() {
        let someValue: Some = subject.property(named: "vsome")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "vsomeWithProtocol")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "vprotocol")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "vgeneric")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "vgeneric")
        XCTAssertNotNil(generic)
    }

    func test_weak_var_optional() {
        let someValue: Some? = subject.property(named: "vsomeOptional")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolOptional")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolOptional")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericOptional")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "vgenericOptional")
        XCTAssertNotNil(generic)
    }

    func test_weak_var_optional_be_nil() {
        let someValue: Some? = subject.property(named: "vsomeOptionalNil")
        XCTAssertNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolOptionalNil")
        XCTAssertNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolOptionalNil")
        XCTAssertNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericOptionalNil")
        XCTAssertNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "vgenericOptionalNil")
        XCTAssertNil(generic)
    }

    func test_weak_var_implicitly_optional() {
        let someValue: Some? = subject.property(named: "vsomeImplicitly")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolImplicitly")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolImplicitly")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericImplicitly")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "vgenericImplicitly")
        XCTAssertNotNil(generic)
    }

    func test_weak_var_implicitly_optional_be_nil() {
        let someValue: Some? = subject.property(named: "vsomeImplicitlyNil")
        XCTAssertNil(someValue)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolImplicitlyNil")
        XCTAssertNil(someWithProtocol)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolImplicitlyNil")
        XCTAssertNil(protocol_)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericImplicitlyNil")
        XCTAssertNil(genericProtocol)

        let generic: SomeGeneric? = subject.property(named: "vgenericImplicitlyNil")
        XCTAssertNil(generic)
    }

    // MARK: - strong types

    func test_strong_let_let() {
        let someValue: Some = subject.property(named: "lsome")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "lsomeWithProtocol")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "lprotocol")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "lgeneric")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "lgeneric")
        XCTAssertNotNil(generic)
    }

    func test_strong_let_optional() {
        let someValue: Some = subject.property(named: "lsomeOptional")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "lsomeWithProtocolOptional")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "lprotocolOptional")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "lgenericOptional")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "lgenericOptional")
        XCTAssertNotNil(generic)
    }

    func test_strong_let_implicitly_optional() {
        let someValue: Some = subject.property(named: "lsomeImplicitly")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "lsomeWithProtocolImplicitly")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "lprotocolImplicitly")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "lgenericImplicitly")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "lgenericImplicitly")
        XCTAssertNotNil(generic)
    }

    func test_strong_var_let() {
        let someValue: Some = subject.property(named: "vsome")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "vsomeWithProtocol")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "vprotocol")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "vgeneric")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "vgeneric")
        XCTAssertNotNil(generic)
    }

    func test_strong_var_optional() {
        let someValue: Some = subject.property(named: "vsomeOptional")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "vsomeWithProtocolOptional")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "vprotocolOptional")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "vgenericOptional")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "vgenericOptional")
        XCTAssertNotNil(generic)
    }

    func test_strong_var_implicitly_optional() {
        let someValue: Some = subject.property(named: "vsomeImplicitly")
        XCTAssertNotNil(someValue)

        let someWithProtocol: SomeWithProtocol = subject.property(named: "vsomeWithProtocolImplicitly")
        XCTAssertNotNil(someWithProtocol)

        let protocol_: SomeWithProtocol = subject.property(named: "vprotocolImplicitly")
        XCTAssertNotNil(protocol_)

        let genericProtocol: SomeGenericProtocol = subject.property(named: "vgenericImplicitly")
        XCTAssertNotNil(genericProtocol)

        let generic: SomeGeneric = subject.property(named: "vgenericImplicitly")
        XCTAssertNotNil(generic)
    }
}

private protocol SomeGenericProtocol {
    init()
}

private class SomeGeneric: SomeGenericProtocol {
    required init() {}
}

private protocol SomeProtocol {}

private class SomeWithProtocol: SomeProtocol {}

private class Some {}

private class Container<T: SomeGenericProtocol> {
    let lsome = Some()
    let lsomeWithProtocol = SomeWithProtocol()
    let lprotocol: SomeProtocol = SomeWithProtocol()
    let lgeneric = T()

    let lsomeOptional: Some? = Some()
    let lsomeWithProtocolOptional: SomeWithProtocol? = SomeWithProtocol()
    let lprotocolOptional: SomeProtocol? = SomeWithProtocol()
    let lgenericOptional: T? = T()

    let lsomeOptionalNil: Some? = nil
    let lsomeWithProtocolOptionalNil: SomeWithProtocol? = nil
    let lprotocolOptionalNil: SomeProtocol? = nil
    let lgenericOptionalNil: T? = nil

    let lsomeImplicitly: Some! = Some()
    let lsomeWithProtocolImplicitly: SomeWithProtocol! = SomeWithProtocol()
    let lprotocolImplicitly: SomeProtocol! = SomeWithProtocol()
    let lgenericImplicitly: T! = T()

    let lsomeImplicitlyNil: Some! = nil
    let lsomeWithProtocolImplicitlyNil: SomeWithProtocol! = nil
    let lprotocolImplicitlyNil: SomeProtocol! = nil
    let lgenericImplicitlyNil: T! = nil

    var vsome = Some()
    var vsomeWithProtocol = SomeWithProtocol()
    var vprotocol: SomeProtocol = SomeWithProtocol()
    var vgeneric = T()

    var vsomeOptional: Some? = Some()
    var vsomeWithProtocolOptional: SomeWithProtocol? = SomeWithProtocol()
    var vprotocolOptional: SomeProtocol? = SomeWithProtocol()
    var vgenericOptional: T? = T()

    var vsomeOptionalNil: Some?
    var vsomeWithProtocolOptionalNil: SomeWithProtocol?
    var vprotocolOptionalNil: SomeProtocol?
    var vgenericOptionalNil: T?

    var vsomeImplicitly: Some! = Some()
    var vsomeWithProtocolImplicitly: SomeWithProtocol! = SomeWithProtocol()
    var vprotocolImplicitly: SomeProtocol! = SomeWithProtocol()
    var vgenericImplicitly: T! = T()

    var vsomeImplicitlyNil: Some!
    var vsomeWithProtocolImplicitlyNil: SomeWithProtocol!
    var vprotocolImplicitlyNil: SomeProtocol!
    var vgenericImplicitlyNil: T!
}
