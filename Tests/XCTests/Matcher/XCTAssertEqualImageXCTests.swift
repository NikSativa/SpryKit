import Foundation
import SpryKit
import XCTest

final class XCTAssertEqualImageXCTests: XCTestCase {
    func test_images() {
        XCTAssertEqualImage(Image.spry.testImage, Image.spry.testImage)
        XCTAssertNotEqualImage(Image.spry.testImage, Image.spry.testImage2)

        XCTAssertEqualImage(Image.spry.testImage) {
            return Image.spry.testImage
        }

        XCTAssertNotEqualImage(Image.spry.testImage) {
            return Image.spry.testImage2
        }
    }

    func test_a_nil_image_is_reported() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualImage(nil, Image.spry.testImage)
        }, issueMatcher: { _ in true })

        XCTExpectFailure(failingBlock: {
            XCTAssertEqualImage(Image.spry.testImage, nil)
        }, issueMatcher: { _ in true })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualImage(nil, Image.spry.testImage)
        }, issueMatcher: { _ in true })
    }

    func test_a_thrown_error_is_reported() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualImage(Image.spry.testImage) {
                try Self.broken()
            }
        }, issueMatcher: { _ in true })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualImage(Image.spry.testImage) {
                try Self.broken()
            }
        }, issueMatcher: { _ in true })
    }

    func test_unequal_images_are_reported() {
        XCTExpectFailure(failingBlock: {
            XCTAssertEqualImage(Image.spry.testImage, Image.spry.testImage2)
        }, issueMatcher: { _ in true })

        XCTExpectFailure(failingBlock: {
            XCTAssertNotEqualImage(Image.spry.testImage, Image.spry.testImage)
        }, issueMatcher: { _ in true })
    }

    private static func broken() throws -> Image? {
        throw ImageTestError.broken
    }
}

private enum ImageTestError: Error {
    case broken
}
