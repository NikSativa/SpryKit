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
        XCTAssertNil(PlatformImage(data: Data()))

        XCTAssertEqual(PlatformImage(image).sdk, image)
        XCTAssertEqualImage(PlatformImage(image).sdk, image)
    }
}

#if os(iOS) || os(tvOS)
import UIKit

private enum Screen {
    @MainActor static var scale: CGFloat {
        return UIScreen.main.scale
    }
}

#elseif os(watchOS)
import WatchKit

private enum Screen {
    @MainActor static var scale: CGFloat {
        return WKInterfaceDevice.current().screenScale
    }
}

#elseif (swift(>=5.9) && os(visionOS))
public enum Screen {
    /// visionOS doesn't have a screen scale, so we'll just use 2x for Tests.
    /// override it on your own risk.
    @MainActor public static var scale: CGFloat?
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

    #elseif (swift(>=5.9) && os(visionOS))
    init?(data: Data) {
        let scale = syncMainThread { Screen.scale }

        if let scale,
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

    #elseif os(iOS) || os(tvOS) || os(watchOS)
    init?(data: Data) {
        let scale = syncMainThread { Screen.scale }

        if let image = UIImage(data: data, scale: scale) {
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

#if swift(>=5.10)
@inline(__always)
private func syncMainThread<T: Sendable>(_ callback: @MainActor () -> T) -> T {
    if Thread.isMainThread {
        MainActor.assumeIsolated {
            callback()
        }
    } else {
        DispatchQueue.main.sync {
            callback()
        }
    }
}
#else
@inline(__always)
private func syncMainThread<T>(_ callback: @MainActor () -> T) -> T {
    if Thread.isMainThread {
        callback()
    } else {
        DispatchQueue.main.sync {
            callback()
        }
    }
}
#endif
