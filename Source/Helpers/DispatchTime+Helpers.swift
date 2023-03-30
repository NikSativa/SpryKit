import Foundation

// MARK: - DispatchTime.spry

public extension DispatchTime {
    enum spry {
        // namespace
    }
}

public extension DispatchTime.spry {
    static func testMake(secondsFromNow interval: Double) -> DispatchTime {
        return .now() + interval
    }

    static func argument(secondsFromNow interval: Double) -> Argument {
        return .validator { value in
            guard let value = value as? DispatchTime else {
                return false
            }

            let fromNow = DispatchTime.spry.testMake(secondsFromNow: interval)
            let diff: dispatch_time_t
            if value > fromNow {
                diff = value.rawValue - fromNow.rawValue
            } else {
                diff = fromNow.rawValue - value.rawValue
            }
            return diff < 1000000
        }
    }
}
