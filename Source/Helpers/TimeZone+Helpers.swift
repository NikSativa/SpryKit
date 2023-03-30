import Foundation

// MARK: - TimeZone.spry

public extension TimeZone {
    enum spry {
        // namespace
    }
}

public extension TimeZone.spry {
    static func testMake(secondsFromGMT: Int = 0) -> TimeZone {
        return TimeZone(secondsFromGMT: secondsFromGMT)!
    }
}
