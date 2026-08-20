import Foundation

/// Guards the recursive structural comparison against cyclic and very deep object graphs.
///
/// A reference cycle would otherwise recurse forever, and a long chain of nested values overflows
/// the stack long before that — the limit is set by the smallest stack a test body runs on, which
/// is the Swift Testing cooperative pool rather than the main thread.
internal final class ComparisonContext {
    /// Deeper graphs overflow the smallest stack a test body can run on.
    ///
    /// Measured against the Swift Testing cooperative pool, whose 512 KB stack gives out at roughly
    /// twice this figure. Every nested value counts, optional wrappers included, so a chain of
    /// `Node?` links spends two levels per link.
    static let maximumDepth: Int = 100

    /// Rendering a diff carries far more per-level state than comparing does, so it gives out on the
    /// same stack much sooner. A diff nested this deep is unreadable anyway.
    static let maximumDiffDepth: Int = 30

    private var depth: Int = 0
    private var pairsInProgress: Set<ReferencePair> = []

    func descend(comparing lhs: Any, and rhs: Any) {
        depth += 1

        guard depth <= Self.maximumDepth else {
            Constant.FatalError.comparisonTooDeep(limit: Self.maximumDepth, lhs: lhs, rhs: rhs)
        }
    }

    func ascend() {
        depth -= 1
    }

    /// Marks a pair of objects as being compared, or reports that it already is.
    ///
    /// Re-entering the same pair means the graph loops back on itself. The pair is treated as equal:
    /// anything that actually differs is found on some other branch of the same walk.
    func beginComparing(_ pair: ReferencePair) -> Bool {
        return pairsInProgress.insert(pair).inserted
    }

    func endComparing(_ pair: ReferencePair) {
        pairsInProgress.remove(pair)
    }
}
