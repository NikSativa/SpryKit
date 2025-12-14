#if canImport(Testing)
import Foundation
import SpryKit
import Testing

#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif // canImport(Testing)

@MainActor
@Suite("CrossPlatform Tests", .serialized)
struct CrossPlatformTests {
    init() {
        #if os(iOS) || os(tvOS)
        PlatformImage.scale = UIScreen.main.scale
        #elseif os(watchOS)
        PlatformImage.scale = WKInterfaceDevice.current().screenScale
        #endif // canImport(Testing)
    }

    @Test("Scale")
    func scale() {
        let image = Image.spry.testImage

        #expect(PlatformImage(image).pngData() == image.pngData())
        #expect(PlatformImage(image).sdk.testData() == image.testData())
        #expect(PlatformImage(data: image.pngData() ?? Data())?.sdk.pngData() == image.pngData())
        #expect(PlatformImage(data: Data()) == nil)

        #expect(PlatformImage(image).sdk == image)
        expectEqualImage({ PlatformImage(image).sdk }, { image })
    }
}

private struct PlatformImage {
    #if swift(>=6.0)
    nonisolated(unsafe) static var scale: CGFloat = 1
    #else
    static var scale: CGFloat = 1
    #endif // canImport(Testing)

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
        sdk.png
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
        sdk.pngData()
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
        sdk.pngData()
    }
    #endif // canImport(Testing)
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
        png
    }
}
#endif // canImport(Testing)
#endif // canImport(Testing)
