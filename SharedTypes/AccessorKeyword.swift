#if swift(>=6.0)
import Foundation

public enum AccessorKeyword: String, Hashable, CaseIterable {
    case get
    case set
    case async
    case `throws`
}
#endif
