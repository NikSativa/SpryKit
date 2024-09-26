import Foundation
import SpryKit
import XCTest

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

final class CrossPlatformTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        await MainActor.run {
            #if os(iOS) || os(tvOS)
            PlatformImage.scale = UIScreen.main.scale
            #elseif os(watchOS)
            PlatformImage.scale = WKInterfaceDevice.current().screenScale
            #endif
        }
    }

    func test_scale() {
        let image = Image.spry.testImage

        XCTAssertEqual(PlatformImage(image).pngData(), image.pngData())
        XCTAssertEqual(PlatformImage(image).sdk.testData(), image.testData())
        XCTAssertEqual(PlatformImage(data: image.pngData() ?? Data())?.sdk.pngData(), image.pngData())
        XCTAssertNil(PlatformImage(data: Data()))

        XCTAssertEqual(PlatformImage(image).sdk, image)
        XCTAssertEqualImage(PlatformImage(image).sdk, image)
    }
}

private struct PlatformImage {
    #if swift(>=6.0)
    nonisolated(unsafe) static var scale: CGFloat = 1
    #else
    static var scale: CGFloat = 1
    #endif

    let sdk: Image

    init(_ image: Image) {
        self.sdk = image
    }

    #if os(macOS)
    init?(data: Data) {
        if let image = NSImage(data: data) {
            self.init(image)
        } else {
            return nil
        }
    }

    func pngData() -> Data? {
        return sdk.png
    }

    #elseif os(iOS) || os(tvOS) || os(watchOS)
    init?(data: Data) {
        if let image = UIImage(data: data, scale: Self.scale) {
            self.init(image)
        } else {
            return nil
        }
    }

    func pngData() -> Data? {
        return sdk.pngData()
    }

    #elseif supportsVisionOS
    init?(data: Data) {
        if let image = UIImage(data: data, scale: Self.scale) {
            self.init(image)
        } else if let image = UIImage(data: data) {
            self.init(image)
        } else {
            return nil
        }
    }

    func pngData() -> Data? {
        return sdk.pngData()
    }
    #endif
}

#if os(macOS)
private extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}

private extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

private extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }

    func pngData() -> Data? {
        return png
    }
}
#endif
