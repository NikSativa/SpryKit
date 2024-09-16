#if swift(>=6.0)
import Foundation

/// Parameters for @SpryableVar
public enum VarKeyword: String, Hashable, CaseIterable {
    /// generate 'get'. Always generating it
    case get
    /// generate 'set'
    case set
    /// add 'async' parameter to 'get'
    case async
    /// add 'throws' parameter to 'get'
    case `throws`
}
#endif
