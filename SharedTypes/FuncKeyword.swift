#if swift(>=6.0)
import Foundation

/// Parameters for @SpryableFunc
public enum FuncKeyword: String, Hashable, CaseIterable {
    /// spryify parameter as Argument.closure
    case asArgument
    /// spryify parameter as real closure which you can handle from stub. Default behavior
    case asRealClosure
}
#endif
