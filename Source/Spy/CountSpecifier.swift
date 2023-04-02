import Foundation

/// Used when specifying if a function was called.
public enum CountSpecifier {
    /// Will only succeed if the function was called exactly the number of times specified.
    /// - timesCalled == .exactly(N)
    case exactly(Int)
    /// Will only succeed if the function was called the number of times specified or more.
    /// - timesCalled >= .atLeast(N)
    case atLeast(Int)
    /// Will only succeed if the function was called the number of times specified or less.
    /// - timesCalled <= .atMost(N)
    case atMost(Int)
}
