import Foundation
import NSpry
import XCTest

final class XCTAssertEqualImageTests: XCTestCase {
    func test_images() {
        XCTAssertEqualImage(Image.testImage, Image.testImage)
        XCTAssertNotEqualImage(Image.testImage, Image.testImage2)

        XCTAssertEqualImage(Image.testImage) {
            return Image.testImage
        }

        XCTAssertNotEqualImage(Image.testImage) {
            return Image.testImage2
        }
    }
}
