#if canImport(CwlPreconditionTesting) && (os(macOS) || os(iOS) || os(visionOS)) && (arch(x86_64) || arch(arm64))
import CwlPreconditionTesting
import Foundation
import Threading

/// Serializes `catchBadInstruction(in:)` across the process.
///
/// `catchBadInstruction(in:)` turns exclusivity checking off through a process-wide runtime flag while its block runs.
/// Concurrent calls, such as traps caught by tests that Swift Testing runs in parallel, turn it back on under another
/// running block, and a trap unwound past an access recorded meanwhile crashes the test process on a later access.
private let badInstructionCatchingMutex = PThread(kind: .recursive)

func catchBadInstructionSerially(in block: @escaping () -> Void) -> BadInstructionException? {
    badInstructionCatchingMutex.lock()
    defer {
        badInstructionCatchingMutex.unlock()
    }

    return catchBadInstruction(in: block)
}
#endif
