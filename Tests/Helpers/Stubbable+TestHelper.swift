import Foundation
import NSpry

struct StubbableError: Error, Equatable {
    let id: String
}

/// basic protocol
protocol SpecialString {
    func myStringValue() -> String
}

/// final class
final class AlwaysLowerCase: SpecialString {
    let value: String

    init(value: String) {
        self.value = value
    }

    func myStringValue() -> String {
        return value.lowercased()
    }
}

/// Non-final class
final class NumbersOnly: SpecialString {
    let value: Int

    required init(value: Int) {
        self.value = value
    }

    func myStringValue() -> String {
        return String(value)
    }
}

/// stubbed version
final class StubSpecialString: SpecialString, Stubbable {
    enum ClassFunction: String, StringRepresentable {
        case none
    }

    enum Function: String, StringRepresentable {
        case myStringValue = "myStringValue()"
    }

    func myStringValue() -> String {
        return stubbedValue()
    }
}

/// protocol with self or associated type requirements
protocol ProtocolWithSelfRequirement {
    func me() -> Self
}

final class ProtocolWithSelfRequirementImplemented: ProtocolWithSelfRequirement {
    func me() -> ProtocolWithSelfRequirementImplemented {
        return self
    }
}

/// Stubbable example class
final class StubbableTestHelper: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case classFunction = "classFunction()"
    }

    enum Function: String, StringRepresentable {
        case myProperty
        case giveMeAString = "giveMeAString()"
        case hereAreTwoStrings = "hereAreTwoStrings(string1:string2:)"
        case hereComesATuple = "hereComesATuple()"
        case hereComesAProtocol = "hereComesAProtocol()"
        case hereComesProtocolsInATuple = "hereComesProtocolsInATuple()"
        case hereComesProtocolWithSelfRequirements = "hereComesProtocolWithSelfRequirements(object:)"
        case hereComesAClosure = "hereComesAClosure()"
        case giveMeAStringWithFallbackValue = "giveMeAStringWithFallbackValue()"
        case giveMeAnOptional = "giveMeAnOptional()"
        case giveMeAString_string = "giveMeAString(string:)"
        case giveMeAVoid = "giveMeAVoid()"
        case takeAnOptionalString = "takeAnOptionalString(string:)"
        case takeUnnamedArgument = "takeUnnamedArgument(_:)"
        case callThisCompletion = "callThisCompletion(string:closure:)"
        case throwingFunction = "throwingFunction()"
    }

    var myProperty: String {
        return spryify()
    }

    func giveMeAString() -> String {
        return spryify()
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        return spryify(arguments: string1, string2)
    }

    func hereComesATuple() -> (String, String) {
        return spryify()
    }

    func hereComesAProtocol() -> SpecialString {
        return spryify()
    }

    func hereComesProtocolsInATuple() -> (SpecialString, SpecialString) {
        return spryify()
    }

    func hereComesProtocolWithSelfRequirements<T: ProtocolWithSelfRequirement>(object _: T) -> T {
        return spryify()
    }

    func hereComesAClosure() -> () -> String {
        return spryify()
    }

    var fallbackValueForgiveMeAStringWithFallbackValue: String?
    func giveMeAStringWithFallbackValue() -> String? {
        return spryify(fallbackValue: fallbackValueForgiveMeAStringWithFallbackValue)
    }

    func giveMeAnOptional() -> String? {
        return spryify()
    }

    func giveMeAString(string: String) -> String {
        return spryify(arguments: string)
    }

    func giveMeAVoid() {
        return spryify()
    }

    func takeAnOptionalString(string: String?) -> String {
        return spryify(arguments: string)
    }

    func takeUnnamedArgument(_ unnamed: String) -> Bool {
        return spryify(arguments: unnamed)
    }

    func callThisCompletion(string: String, closure: @escaping () -> Void) {
        return spryify(arguments: string, closure)
    }

    func throwingFunction() throws {
        return try spryifyThrows()
    }

    static func classFunction() -> String {
        return spryify()
    }
}
