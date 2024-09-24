import Foundation
import SpryKit
import XCTest

final class CrossPlatformTests: XCTestCase {
    @MainActor
    func test_scale() {
        let image = Image.spry.testImage

        XCTAssertEqual(PlatformImage(image).pngData(), image.pngData())
        XCTAssertEqual(PlatformImage(image).sdk.testData(), image.testData())
        XCTAssertEqual(PlatformImage(data: image.pngData() ?? Data())?.sdk.pngData(), image.pngData())
        #if !os(macOS)
        XCTAssertEqual(PlatformImage(image).jpegData(compressionQuality: 1), image.jpegData(compressionQuality: 1))
        XCTAssertEqual(PlatformImage(image).jpegData(compressionQuality: 0.5), image.jpegData(compressionQuality: 0.5))
        #endif
        XCTAssertNil(PlatformImage(data: Data()))

        XCTAssertEqual(PlatformImage(image).sdk, image)
        XCTAssertEqualImage(PlatformImage(image).sdk, image)
    }
}

#if os(iOS) || os(tvOS)
import UIKit

private enum Screen {
    static var scale: CGFloat {
        if Thread.isMainThread {
            return MainActor.assumeIsolated {
                return UIScreen.main.scale
            }
        } else {
            return DispatchQueue.main.sync {
                return UIScreen.main.scale
            }
        }
    }
}

#elseif os(watchOS)
import WatchKit

private enum Screen {
    static var scale: CGFloat {
        return WKInterfaceDevice.current().screenScale
    }
}

#elseif os(visionOS)
public enum Screen {
    /// visionOS doesn't have a screen scale, so we'll just use 2x for Tests.
    /// override it on your own risk.
    public nonisolated(unsafe) static var scale: CGFloat?
}
#endif

private struct PlatformImage {
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

    #elseif os(visionOS)
    init?(data: Data) {
        if let scale = Screen.scale,
           let image = UIImage(data: data, scale: scale) {
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

    func jpegData(compressionQuality: CGFloat) -> Data? {
        return sdk.jpegData(compressionQuality: CGFloat(compressionQuality))
    }

    #elseif os(iOS) || os(tvOS) || os(watchOS)
    init?(data: Data) {
        if let image = UIImage(data: data, scale: Screen.scale) {
            self.init(image)
        } else {
            return nil
        }
    }

    func pngData() -> Data? {
        return sdk.pngData()
    }

    func jpegData(compressionQuality: CGFloat) -> Data? {
        return sdk.jpegData(compressionQuality: CGFloat(compressionQuality))
    }
    #else
    #error("unsupported os")
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
