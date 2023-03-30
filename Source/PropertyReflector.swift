import Foundation

public struct PropertyReflector {
    private let properties: [String: Any]

    private init(_ properties: [String: Any]) {
        self.properties = properties
    }

    /// unwraps value of any if its optional, if not returns initial
    private static func unwrapOptionalIfPossible(_ any: Any) -> Any {
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional,
              let (_, value) = mirror.children.first else {
            return any
        }
        return value
    }

    private static func readMirror(mirror: Mirror) -> [String: Any] {
        var properties: [String: Any] = [:]

        // read optional value
        for case (let label, let value) in mirror.children {
            // Note ".storage" is appended to lazy var properties
            if let label = label?.replacingOccurrences(of: ".storage", with: "") {
                properties[label] = unwrapOptionalIfPossible(value)
            }
        }

        if let superMirror = mirror.superclassMirror {
            properties = properties.merging(readMirror(mirror: superMirror),
                                            uniquingKeysWith: { a, _ in a })
        }

        return properties
    }

    public static func scan(_ subject: Any?) -> Self {
        guard let subject else {
            return .init([:])
        }

        let mirror = Mirror(reflecting: unwrapOptionalIfPossible(subject))
        let properties = readMirror(mirror: mirror)
        return .init(properties)
    }

    public func property<T>(_: T.Type = T.self, named name: String) -> T {
        return properties[name] as! T
    }
}
