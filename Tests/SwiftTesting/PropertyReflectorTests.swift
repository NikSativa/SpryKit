#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("PropertyReflector Tests", .serialized)
struct PropertyReflectorTests {
    private let subject = PropertyReflector.scan(Container<SomeGeneric>())

    // MARK: - weak types

    @Test("Weak let let")
    func weak_let_let() {
        let someValue: Some? = subject.property(named: "lsome")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocol")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocol")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgeneric")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "lgeneric")
        #expect(generic != nil)
    }

    @Test("Weak let optional")
    func weak_let_optional() {
        let someValue: Some? = subject.property(named: "lsomeOptional")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolOptional")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolOptional")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericOptional")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "lgenericOptional")
        #expect(generic != nil)
    }

    @Test("Weak let optional be nil")
    func weak_let_optional_be_nil() {
        let someValue: Some? = subject.property(named: "lsomeOptionalNil")
        #expect(someValue == nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolOptionalNil")
        #expect(someWithProtocol == nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolOptionalNil")
        #expect(protocol_ == nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericOptionalNil")
        #expect(genericProtocol == nil)

        let generic: SomeGeneric? = subject.property(named: "lgenericOptionalNil")
        #expect(generic == nil)
    }

    @Test("Weak let implicitly optional")
    func weak_let_implicitly_optional() {
        let someValue: Some? = subject.property(named: "lsomeImplicitly")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolImplicitly")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolImplicitly")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericImplicitly")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "lgenericImplicitly")
        #expect(generic != nil)
    }

    @Test("Weak let implicitly optional be nil")
    func weak_let_implicitly_optional_be_nil() {
        let someValue: Some? = subject.property(named: "lsomeImplicitlyNil")
        #expect(someValue == nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolImplicitlyNil")
        #expect(someWithProtocol == nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolImplicitlyNil")
        #expect(protocol_ == nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericImplicitlyNil")
        #expect(genericProtocol == nil)

        let generic: SomeGeneric? = subject.property(named: "lgenericImplicitlyNil")
        #expect(generic == nil)
    }

    @Test("Weak var let")
    func weak_var_let() {
        let someValue: Some? = subject.property(named: "vsome")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocol")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocol")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgeneric")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "vgeneric")
        #expect(generic != nil)
    }

    @Test("Weak var optional")
    func weak_var_optional() {
        let someValue: Some? = subject.property(named: "vsomeOptional")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolOptional")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolOptional")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericOptional")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "vgenericOptional")
        #expect(generic != nil)
    }

    @Test("Weak var optional be nil")
    func weak_var_optional_be_nil() {
        let someValue: Some? = subject.property(named: "vsomeOptionalNil")
        #expect(someValue == nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolOptionalNil")
        #expect(someWithProtocol == nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolOptionalNil")
        #expect(protocol_ == nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericOptionalNil")
        #expect(genericProtocol == nil)

        let generic: SomeGeneric? = subject.property(named: "vgenericOptionalNil")
        #expect(generic == nil)
    }

    @Test("Weak var implicitly optional")
    func weak_var_implicitly_optional() {
        let someValue: Some? = subject.property(named: "vsomeImplicitly")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolImplicitly")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolImplicitly")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericImplicitly")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "vgenericImplicitly")
        #expect(generic != nil)
    }

    @Test("Weak var implicitly optional be nil")
    func weak_var_implicitly_optional_be_nil() {
        let someValue: Some? = subject.property(named: "vsomeImplicitlyNil")
        #expect(someValue == nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolImplicitlyNil")
        #expect(someWithProtocol == nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolImplicitlyNil")
        #expect(protocol_ == nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericImplicitlyNil")
        #expect(genericProtocol == nil)

        let generic: SomeGeneric? = subject.property(named: "vgenericImplicitlyNil")
        #expect(generic == nil)
    }

    // MARK: - strong types

    @Test("Strong let let")
    func strong_let_let() {
        let someValue: Some? = subject.property(named: "lsome")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocol")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocol")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgeneric")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "lgeneric")
        #expect(generic != nil)
    }

    @Test("Strong let optional")
    func strong_let_optional() {
        let someValue: Some? = subject.property(named: "lsomeOptional")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolOptional")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolOptional")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericOptional")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "lgenericOptional")
        #expect(generic != nil)
    }

    @Test("Strong let implicitly optional")
    func strong_let_implicitly_optional() {
        let someValue: Some? = subject.property(named: "lsomeImplicitly")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "lsomeWithProtocolImplicitly")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "lprotocolImplicitly")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "lgenericImplicitly")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "lgenericImplicitly")
        #expect(generic != nil)
    }

    @Test("Strong var let")
    func strong_var_let() {
        let someValue: Some? = subject.property(named: "vsome")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocol")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocol")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgeneric")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "vgeneric")
        #expect(generic != nil)
    }

    @Test("Strong var optional")
    func strong_var_optional() {
        let someValue: Some? = subject.property(named: "vsomeOptional")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolOptional")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolOptional")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericOptional")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "vgenericOptional")
        #expect(generic != nil)
    }

    @Test("Strong var implicitly optional")
    func strong_var_implicitly_optional() {
        let someValue: Some? = subject.property(named: "vsomeImplicitly")
        #expect(someValue != nil)

        let someWithProtocol: SomeWithProtocol? = subject.property(named: "vsomeWithProtocolImplicitly")
        #expect(someWithProtocol != nil)

        let protocol_: SomeWithProtocol? = subject.property(named: "vprotocolImplicitly")
        #expect(protocol_ != nil)

        let genericProtocol: SomeGenericProtocol? = subject.property(named: "vgenericImplicitly")
        #expect(genericProtocol != nil)

        let generic: SomeGeneric? = subject.property(named: "vgenericImplicitly")
        #expect(generic != nil)
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
#endif // canImport(Testing)
