import CoreGraphics
import Foundation

extension Optional: SpryEquatable where Wrapped: SpryEquatable {}
extension Array: SpryEquatable where Element: SpryEquatable {}
extension Dictionary: SpryEquatable where Value: SpryEquatable {}

extension NSObject: SpryEquatable {}
extension String: SpryEquatable {}
extension Bool: SpryEquatable {}
extension CGFloat: SpryEquatable {}
extension Float: SpryEquatable {}
extension Double: SpryEquatable {}
extension Int: SpryEquatable {}
extension Int8: SpryEquatable {}
extension Int16: SpryEquatable {}
extension Int32: SpryEquatable {}
extension Int64: SpryEquatable {}
extension UInt: SpryEquatable {}
extension UInt8: SpryEquatable {}
extension UInt16: SpryEquatable {}
extension UInt32: SpryEquatable {}
extension UInt64: SpryEquatable {}
extension Notification: SpryEquatable {}
extension Notification.Name: SpryEquatable {}
extension DispatchTime: SpryEquatable {}
extension DispatchTimeInterval: SpryEquatable {}
extension URL: SpryEquatable {}
extension URLRequest: SpryEquatable {}
extension TimeZone: SpryEquatable {}
extension Date: SpryEquatable {}
extension Data: SpryEquatable {}
