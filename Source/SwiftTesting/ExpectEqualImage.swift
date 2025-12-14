#if canImport(Testing)
import Foundation
import Testing

/// Verifies that two images are equal by comparing their PNG data.
///
/// ## Examples ##
/// ```swift
/// @Test func testImageEquality() {
///     let image1 = Image.spry.testImage
///     let image2 = Image.spry.testImage
///     expectEqualImage(image1, image2)
/// }
/// ```
///
/// - Parameter expression1: The first image expression
/// - Parameter expression2: The second image expression
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectEqualImage(_ expression1: () throws -> Image?,
                             _ expression2: () throws -> Image?,
                             _ message: String = "",
                             sourceLocation: SourceLocation = #_sourceLocation) {
    do {
        guard let lhs = try expression1() else {
            Issue.record("\(message). First image is nil", sourceLocation: sourceLocation)
            return
        }
        guard let rhs = try expression2() else {
            Issue.record("\(message). Second image is nil", sourceLocation: sourceLocation)
            return
        }

        #expect(lhs.testData() == rhs.testData(), "\(message)", sourceLocation: sourceLocation)
    } catch {
        Issue.record("\(message). \(error.localizedDescription)", sourceLocation: sourceLocation)
    }
}

/// Verifies that two images are not equal by comparing their PNG data.
///
/// - Parameter expression1: The first image expression
/// - Parameter expression2: The second image expression
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectNotEqualImage(_ expression1: () throws -> Image?,
                                _ expression2: () throws -> Image?,
                                _ message: String = "",
                                sourceLocation: SourceLocation = #_sourceLocation) {
    do {
        guard let lhs = try expression1() else {
            Issue.record("\(message). First image is nil", sourceLocation: sourceLocation)
            return
        }
        guard let rhs = try expression2() else {
            Issue.record("\(message). Second image is nil", sourceLocation: sourceLocation)
            return
        }

        #expect(lhs.testData() != rhs.testData(), "\(message)", sourceLocation: sourceLocation)
    } catch {
        Issue.record("\(message). \(error.localizedDescription)", sourceLocation: sourceLocation)
    }
}

/// Verifies that two images are equal by comparing their PNG data (alternative parameter order).
///
/// - Parameter expression2: The second image expression
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Parameter expression1: The first image expression
public func expectEqualImage(_ expression2: () throws -> Image?,
                             _ message: String = "",
                             sourceLocation: SourceLocation = #_sourceLocation,
                             _ expression1: () throws -> Image?) {
    expectEqualImage(expression1, expression2, message, sourceLocation: sourceLocation)
}

/// Verifies that two images are not equal by comparing their PNG data (alternative parameter order).
///
/// - Parameter expression2: The second image expression
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Parameter expression1: The first image expression
public func expectNotEqualImage(_ expression2: () throws -> Image?,
                                _ message: String = "",
                                sourceLocation: SourceLocation = #_sourceLocation,
                                _ expression1: () throws -> Image?) {
    expectNotEqualImage(expression1, expression2, message, sourceLocation: sourceLocation)
}

#endif // canImport(Testing)
