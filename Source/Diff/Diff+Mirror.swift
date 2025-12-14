import Foundation

public extension Spry {
    /// Builds list of differences between 2 objects using structure reflection.
    ///
    /// This method uses Mirror reflection to compare object structures, providing hierarchical diff output.
    /// Perfect for comparing complex objects, dictionaries, sets, and collections.
    ///
    /// ## Examples ##
    /// ```swift
    /// struct User {
    ///     let id: Int
    ///     let name: String
    /// }
    /// let user1 = User(id: 1, name: "Alice")
    /// let user2 = User(id: 2, name: "Bob")
    /// let diff = Spry.diffMirror(user1, user2)
    /// // Returns: ["name:\n|\tReceived: Bob\n|\tExpected: Alice", "id:\n|\tReceived: 2\n|\tExpected: 1"]
    /// ```
    ///
    /// - Parameters:
    ///   - expected: Expected value
    ///   - received: Received value
    ///   - indentationType: Style of indentation to use (`.pipe` or `.tab`)
    ///   - skipPrintingOnDiffCount: Skips the printing of the object when a collection has a different count
    ///   - nameLabels: Labels for expected/received/missing/extra values
    /// - Returns: Array of difference strings
    static func diffMirror<T>(_ expected: T,
                              _ received: T,
                              indentationType: SpryDiffIndentationType = .pipe,
                              skipPrintingOnDiffCount: Bool = false,
                              nameLabels: SpryDiffNameLabels = .expectation) -> [String] {
        Differ(indentationType: indentationType, skipPrintingOnDiffCount: skipPrintingOnDiffCount, nameLabels: nameLabels)
            .diff(expected, received)
    }

    /// Builds list of differences between 2 objects as structured lines.
    ///
    /// - Parameters:
    ///   - expected: Expected value
    ///   - received: Received value
    ///   - indentationType: Style of indentation to use
    ///   - skipPrintingOnDiffCount: Skips the printing of the object when a collection has a different count
    ///   - nameLabels: Labels for expected/received/missing/extra values
    /// - Returns: Array of difference lines
    static func diffMirrorLines<T>(_ expected: T,
                                   _ received: T,
                                   indentationType: SpryDiffIndentationType = .pipe,
                                   skipPrintingOnDiffCount: Bool = false,
                                   nameLabels: SpryDiffNameLabels = .expectation) -> [SpryDiffLine] {
        Differ(indentationType: indentationType, skipPrintingOnDiffCount: skipPrintingOnDiffCount, nameLabels: nameLabels)
            .diffLines(expected, received)
    }
}

// MARK: - Public Types

/// Styling of the diff indentation.
/// `pipe` example:
///     address:
///     |    street:
///     |    |    Received: 2nd Street
///     |    |    Expected: Times Square
/// `tab` example:
///     address:
///         street:
///             Received: 2nd Street
///             Expected: Times Square
public enum SpryDiffIndentationType: String, CaseIterable {
    case pipe = "|\t"
    case tab = "\t"
}

public struct SpryDiffNameLabels {
    let expected: String
    let received: String
    let missing: String
    let extra: String

    public init(expected: String, received: String, missing: String, extra: String) {
        self.expected = expected
        self.received = received
        self.missing = missing
        self.extra = extra
    }

    public static var expectation: Self {
        Self(expected: "Expected",
             received: "Received",
             missing: "Missing",
             extra: "Extra")
    }

    public static var comparing: Self {
        Self(expected: "Previous",
             received: "Current",
             missing: "Removed",
             extra: "Added")
    }
}

public struct SpryDiffLine {
    public let contents: String
    public let indentationLevel: Int
    public let children: [SpryDiffLine]
    public let canBeOrdered: Bool

    public var hasChildren: Bool { !children.isEmpty }

    public init(contents: String,
                indentationLevel: Int,
                canBeOrdered: Bool,
                children: [SpryDiffLine] = []) {
        self.contents = contents
        self.indentationLevel = indentationLevel
        self.children = children
        self.canBeOrdered = canBeOrdered
    }

    public func generateContents(indentationType: SpryDiffIndentationType) -> String {
        let indentationString = indentation(level: indentationLevel, indentationType: indentationType)
        let childrenContents = children
            .sorted { lhs, rhs in
                guard lhs.canBeOrdered, rhs.canBeOrdered else {
                    return false
                }

                return lhs.contents < rhs.contents
            }
            .map { $0.generateContents(indentationType: indentationType) }
            .joined()
        return "\(indentationString)\(contents)\n" + childrenContents
    }

    private func indentation(level: Int, indentationType: SpryDiffIndentationType) -> String {
        return (0..<level).reduce("") { acc, _ in acc + "\(indentationType.rawValue)" }
    }
}

// MARK: - Private Implementation

private struct Differ {
    private let indentationType: SpryDiffIndentationType
    private let skipPrintingOnDiffCount: Bool
    private let nameLabels: SpryDiffNameLabels

    init(indentationType: SpryDiffIndentationType,
         skipPrintingOnDiffCount: Bool,
         nameLabels: SpryDiffNameLabels) {
        self.indentationType = indentationType
        self.skipPrintingOnDiffCount = skipPrintingOnDiffCount
        self.nameLabels = nameLabels
    }

    func diff<T>(_ expected: T, _ received: T) -> [String] {
        let lines = diffLines(expected, received, level: 0)
        return buildLineContents(lines: lines)
    }

    func diffLines<T>(_ expected: T, _ received: T, level: Int = 0) -> [SpryDiffLine] {
        let expectedMirror = Mirror(reflecting: expected)
        let receivedMirror = Mirror(reflecting: received)

        if let expectedDecimal = expected as? Decimal, let receivedDecimal = received as? Decimal {
            return expectedDecimal == receivedDecimal ? [] : generateExpectedReceiveLines("\(expectedDecimal)", "\(receivedDecimal)", level)
        }

        guard !expectedMirror.children.isEmpty, !receivedMirror.children.isEmpty else {
            let receivedDump = String(dumping: received)
            if receivedDump != String(dumping: expected) {
                return handleChildless(expected, expectedMirror, received, receivedMirror, level)
            } else if expectedMirror.displayStyle == .enum, receivedDump.hasPrefix("__C.") { // enum and C bridged
                let expectedValue = enumIntValue(for: expected)
                let receivedValue = enumIntValue(for: received)
                if expectedValue != receivedValue {
                    return handleChildless(expectedValue, expectedMirror, receivedValue, receivedMirror, level)
                }
            }
            return []
        }

        // Remove embedding of `some` for optional types, as it offers no value
        guard expectedMirror.displayStyle != .optional else {
            if let expectedUnwrapped = expectedMirror.firstChildenValue, let receivedUnwrapped = receivedMirror.firstChildenValue {
                return diffLines(expectedUnwrapped, receivedUnwrapped, level: level)
            }
            return []
        }

        let hasDiffNumOfChildren = expectedMirror.children.count != receivedMirror.children.count
        switch (expectedMirror.displayStyle, receivedMirror.displayStyle) {
        case (.collection?, .collection?) where hasDiffNumOfChildren,
             (.dictionary?, .dictionary?) where hasDiffNumOfChildren,
             (.set?, .set?) where hasDiffNumOfChildren,
             (.enum?, .enum?) where hasDiffNumOfChildren:
            return [generateDifferentCountBlock(expected, expectedMirror, received, receivedMirror, level)]

        case (.dictionary?, .dictionary?):
            if let expectedDict = expected as? [AnyHashable: Any],
               let receivedDict = received as? [AnyHashable: Any] {
                var resultLines: [SpryDiffLine] = []
                let missingKeys = Set(expectedDict.keys).subtracting(receivedDict.keys)
                let extraKeys = Set(receivedDict.keys).subtracting(expectedDict.keys)
                let commonKeys = Set(receivedDict.keys).intersection(expectedDict.keys)
                for key in commonKeys {
                    let results = diffLines(expectedDict[key], receivedDict[key], level: level + 1)
                    if !results.isEmpty {
                        resultLines.append(SpryDiffLine(contents: "Key \(key.description):", indentationLevel: level, canBeOrdered: true, children: results))
                    }
                }
                if !missingKeys.isEmpty {
                    var missingKeyPairs: [SpryDiffLine] = []
                    for key in missingKeys {
                        missingKeyPairs.append(SpryDiffLine(contents: "\(key.description): \(String(describing: expectedDict[key]))", indentationLevel: level + 1, canBeOrdered: true))
                    }
                    resultLines.append(SpryDiffLine(contents: "\(nameLabels.missing) key pairs:", indentationLevel: level, canBeOrdered: false, children: missingKeyPairs))
                }
                if !extraKeys.isEmpty {
                    var extraKeyPairs: [SpryDiffLine] = []
                    for key in extraKeys {
                        extraKeyPairs.append(SpryDiffLine(contents: "\(key.description): \(String(describing: receivedDict[key]))", indentationLevel: level + 1, canBeOrdered: true))
                    }
                    resultLines.append(SpryDiffLine(contents: "\(nameLabels.extra) key pairs:", indentationLevel: level, canBeOrdered: false, children: extraKeyPairs))
                }
                return resultLines
            }

        case (.set?, .set?):
            if let expectedSet = expected as? Set<AnyHashable>,
               let receivedSet = received as? Set<AnyHashable> {
                let missing = expectedSet.subtracting(receivedSet)
                    .map { unique in
                        SpryDiffLine(contents: "\(nameLabels.missing): \(unique.description)", indentationLevel: level, canBeOrdered: true)
                    }
                let extras = receivedSet.subtracting(expectedSet)
                    .map { unique in
                        SpryDiffLine(contents: "\(nameLabels.extra): \(unique.description)", indentationLevel: level, canBeOrdered: true)
                    }
                return missing + extras
            }

        // Handles different enum cases that have children to prevent printing entire object
        case (.enum?, .enum?) where expectedMirror.children.first?.label != receivedMirror.children.first?.label:
            let expectedPrintable = enumLabelFromFirstChild(expectedMirror) ?? "UNKNOWN"
            let receivedPrintable = enumLabelFromFirstChild(receivedMirror) ?? "UNKNOWN"
            return generateExpectedReceiveLines(expectedPrintable, receivedPrintable, level)

        default:
            break
        }

        var resultLines = [SpryDiffLine]()
        let zipped = zip(expectedMirror.children, receivedMirror.children)
        for (index, zippedValues) in zipped.enumerated() {
            let lhs = zippedValues.0
            let rhs = zippedValues.1
            let childName = "\(expectedMirror.displayStyleDescriptor(index: index))\(lhs.label ?? ""):"
            let results = diffLines(lhs.value, rhs.value, level: level + 1)

            if !results.isEmpty {
                let line = SpryDiffLine(contents: childName,
                                        indentationLevel: level,
                                        canBeOrdered: true,
                                        children: results)
                resultLines.append(line)
            }
        }
        return resultLines
    }

    fileprivate func handleChildless<T>(_ expected: T,
                                        _ expectedMirror: Mirror,
                                        _ received: T,
                                        _ receivedMirror: Mirror,
                                        _ indentationLevel: Int) -> [SpryDiffLine] {
        // Empty collections are "childless", so we may need to generate a different count block instead of treating as a
        // childless enum.
        guard !expectedMirror.canBeEmpty else {
            return [generateDifferentCountBlock(expected, expectedMirror, received, receivedMirror, indentationLevel)]
        }

        let receivedPrintable: String
        let expectedPrintable: String
        // Received mirror has a different number of arguments to expected
        if receivedMirror.children.isEmpty, !expectedMirror.children.isEmpty {
            // Print whole description of received, as it's only a label if childless
            receivedPrintable = String(dumping: received)
            // Get the label from the expected, to prevent printing long list of arguments
            expectedPrintable = enumLabelFromFirstChild(expectedMirror) ?? String(describing: expected)
        } else if expectedMirror.children.isEmpty, !receivedMirror.children.isEmpty {
            receivedPrintable = enumLabelFromFirstChild(receivedMirror) ?? String(describing: received)
            expectedPrintable = String(dumping: expected)
        } else {
            receivedPrintable = String(describing: received)
            expectedPrintable = String(describing: expected)
        }
        return generateExpectedReceiveLines(expectedPrintable, receivedPrintable, indentationLevel)
    }

    private func generateDifferentCountBlock<T>(_ expected: T,
                                                _ expectedMirror: Mirror,
                                                _ received: T,
                                                _ receivedMirror: Mirror,
                                                _ indentationLevel: Int) -> SpryDiffLine {
        var expectedPrintable = "(\(expectedMirror.children.count))"
        var receivedPrintable = "(\(receivedMirror.children.count))"
        if !skipPrintingOnDiffCount {
            expectedPrintable.append(" \(expected)")
            receivedPrintable.append(" \(received)")
        }
        return SpryDiffLine(contents: "Different count:",
                            indentationLevel: indentationLevel,
                            canBeOrdered: false,
                            children: generateExpectedReceiveLines(expectedPrintable, receivedPrintable, indentationLevel + 1))
    }

    private func generateExpectedReceiveLines(_ expected: String,
                                              _ received: String,
                                              _ indentationLevel: Int) -> [SpryDiffLine] {
        return [
            SpryDiffLine(contents: "\(nameLabels.received): \(received)", indentationLevel: indentationLevel, canBeOrdered: false),
            SpryDiffLine(contents: "\(nameLabels.expected): \(expected)", indentationLevel: indentationLevel, canBeOrdered: false)
        ]
    }

    private func buildLineContents(lines: [SpryDiffLine]) -> [String] {
        let linesContents = lines.map { line in line.generateContents(indentationType: indentationType) }
        // In the case of this being a top level failure (e.g. both mirrors have no children, like comparing two
        // primitives `diff(2,3)`, we only want to produce one failure to have proper spacing.
        let isOnlyTopLevelFailure = lines.map(\.hasChildren).filter { $0 }.isEmpty
        if isOnlyTopLevelFailure {
            return [linesContents.joined()]
        } else {
            return linesContents
        }
    }

    /// Creates int value from Objective-C enum.
    private func enumIntValue<T>(for object: T) -> Int {
        withUnsafePointer(to: object) {
            $0.withMemoryRebound(to: Int.self, capacity: 1) {
                $0.pointee
            }
        }
    }
}

// MARK: - String Extensions

private extension String {
    init<T>(dumping object: T) {
        self.init()
        dump(object, to: &self)
        self = withoutDumpArtifacts
    }

    /// Removes the artifacts of using dumping initialiser to improve readability
    private var withoutDumpArtifacts: String {
        replacingOccurrences(of: "- ", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}

// MARK: - Mirror Extensions

/// In the case of an enum with an argument being compared to a different enum case,
/// pull the case name from the mirror
private func enumLabelFromFirstChild(_ mirror: Mirror) -> String? {
    switch mirror.displayStyle {
    case .enum: return mirror.children.first?.label
    default: return nil
    }
}

private extension Mirror {
    func displayStyleDescriptor(index: Int) -> String {
        switch displayStyle {
        case .enum: return "Enum "
        case .collection: return "Collection[\(index)]"
        default: return ""
        }
    }

    /// Used to show "different count" message if mirror has no children,
    /// as some displayStyles can have 0 children.
    var canBeEmpty: Bool {
        switch displayStyle {
        case .collection,
             .dictionary,
             .set:
            return true
        default:
            return false
        }
    }

    var firstChildenValue: Any? {
        children.first?.value
    }
}
