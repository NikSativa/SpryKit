import Foundation

// MARK: - URL.spry

public extension URL {
    enum spry {
        // namespace
    }
}

public extension URL.spry {
    static func testMake(_ string: String = "http://www.some.com") -> URL {
        return URL(string: string).unsafelyUnwrapped
    }
}
