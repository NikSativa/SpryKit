import Foundation
import NSpry
import XCTest

final class XCTAssertEqualImageTests: XCTestCase {
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
}
