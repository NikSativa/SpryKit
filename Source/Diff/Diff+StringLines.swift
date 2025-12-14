import Foundation

public extension String {
    enum spry {
        // namespace
    }

    func spryDiffLines(with other: String) -> String {
        return .spry.diffLines(self, other)
    }
}

public extension Spry {
    /// Builds line-by-line diff between two strings using Myers algorithm.
    ///
    /// This method provides a simple line-by-line diff output with markers:
    /// - ` ` (figure space) for unchanged lines
    /// - `−` for removed lines
    /// - `+` for added lines
    ///
    /// ## Examples ##
    /// ```swift
    /// let diff = Spry.diffLines("line1\nline2", "line1\nline3")
    /// // Returns: "  line1\n− line2\n+ line3"
    /// ```
    ///
    /// - Parameters:
    ///   - first: First string to compare
    ///   - second: Second string to compare
    /// - Returns: Diff string with line markers, or empty string if strings are equal
    static func diffLines(_ first: String, _ second: String) -> String {
        return .spry.diffLines(first, second)
    }
}

public extension String.spry {
    static func diffLines(_ first: String, _ second: String) -> String {
        let differences = computeDiffChunks(first.split(separator: "\n", omittingEmptySubsequences: false)[...],
                                            second.split(separator: "\n", omittingEmptySubsequences: false)[...])
        // If all chunks are common, there's no visible diff → return empty string
        if differences.allSatisfy({ $0.origin == .both }) {
            return ""
        }
        var string = differences.reduce(into: "") { string, diff in
            for line in diff.elements {
                string += "\(diff.origin.marker) \(line)\n"
            }
        }

        string.removeLast()
        return string
    }
}

private struct DiffChunk {
    enum Origin {
        case both
        case removed
        case added

        var marker: String {
            switch self {
            case .both:
                return "\u{2007}"
            case .removed:
                return "−"
            case .added:
                return "+"
            }
        }
    }

    let elements: ArraySlice<Substring>
    let origin: Origin
}

private func computeDiffChunks(_ a: ArraySlice<Substring>,
                               _ b: ArraySlice<Substring>) -> [DiffChunk] {
    let n = a.count
    let m = b.count
    if n == 0, m == 0 {
        return []
    }
    if n == 0 {
        return [DiffChunk(elements: b, origin: .added)]
    }
    if m == 0 {
        return [DiffChunk(elements: a, origin: .removed)]
    }

    let maxD = n + m
    let offset = maxD
    var v = Array(repeating: -1, count: 2 * maxD + 1)
    var trace: [[Int]] = []

    v[offset + 1] = 0

    for d in 0...maxD {
        var current = v // capture state for this d
        for k in stride(from: -d, through: d, by: 2) {
            let kIndex = offset + k
            let x: Int =
                if k == -d || (k != d && v[kIndex - 1] < v[kIndex + 1]) {
                    v[kIndex + 1] // down (insertion)
                } else {
                    v[kIndex - 1] + 1 // right (deletion)
                }
            var y = x - k
            var x2 = x
            // follow snake (matches)
            while x2 < n, y < m, a[a.startIndex + x2] == b[b.startIndex + y] {
                x2 += 1
                y += 1
            }
            current[kIndex] = x2
            if x2 >= n, y >= m {
                trace.append(current)
                return myersBacktrack(a, b, trace: trace, offset: offset)
            }
        }
        trace.append(current)
        v = current
    }

    return []
}

private func myersBacktrack(_ a: ArraySlice<Substring>,
                            _ b: ArraySlice<Substring>,
                            trace: [[Int]],
                            offset: Int) -> [DiffChunk] {
    var x = a.count
    var y = b.count
    var chunks: [DiffChunk] = []

    for d in stride(from: trace.count - 1, through: 0, by: -1) {
        let v = trace[d]
        let k = x - y
        let kIndex = offset + k

        let prevX: Int
        let goDown: Bool
        if k == -d || (k != d && v[kIndex - 1] < v[kIndex + 1]) {
            prevX = v[kIndex + 1]
            goDown = true // insertion in b ("added")
        } else {
            prevX = v[kIndex - 1] + 1
            goDown = false // deletion from a ("removed")
        }
        let prevY = prevX - (x - y)

        // common tail (snake)
        while x > prevX, y > prevY {
            x -= 1
            y -= 1
            let line = a[a.startIndex + x]
            chunks.append(DiffChunk(elements: [line][...], origin: .both))
        }

        // step (if d > 0)
        if d > 0 {
            if goDown {
                // came from down → insertion (added in b)
                y -= 1
                let line = b[b.startIndex + y]
                chunks.append(DiffChunk(elements: [line][...], origin: .added))
            } else {
                // came from right → deletion (removed from a)
                x -= 1
                let line = a[a.startIndex + x]
                chunks.append(DiffChunk(elements: [line][...], origin: .removed))
            }
        }
    }

    return chunks.reversed()
}
