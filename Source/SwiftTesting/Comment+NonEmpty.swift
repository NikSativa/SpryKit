#if canImport(Testing)
import Testing

extension Comment {
    /// Creates a comment only when `message` has a line to print.
    ///
    /// Swift Testing 6.1 traps while printing a failure whose comment has no non-empty line,
    /// so an empty message has to produce no comment at all.
    init?(nonEmpty message: String) {
        guard !message.allSatisfy(\.isNewline) else {
            return nil
        }

        self.init(rawValue: message)
    }
}
#endif
