import Foundation

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit

public typealias Image = UIImage
#elseif os(macOS)
import Cocoa

public typealias Image = NSImage
#else
#error("unsupported os")
#endif

// MARK: - Image.spry

public extension Image {
    enum spry {
        // namespace
    }

    func testData() -> Data? {
        #if os(macOS)
        return png
        #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        return pngData()
        #else
        #error("unsupported os")
        #endif
    }
}

public extension Image.spry {
    #if os(macOS)
    nonisolated(unsafe) static let testImage: Image = .init(systemSymbolName: "circle", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage1: Image = .init(systemSymbolName: "square", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage2: Image = .init(systemSymbolName: "diamond", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage3: Image = .init(systemSymbolName: "octagon", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage4: Image = .init(systemSymbolName: "oval", accessibilityDescription: nil)!
    #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    static let testImage: Image = Self.image(withColor: .blue)
    static let testImage1: Image = Self.image(withColor: .green)
    static let testImage2: Image = Self.image(withColor: .red)
    static let testImage3: Image = Self.image(withColor: .black)
    static let testImage4: Image = Self.image(withColor: .white)

    private static func image(withColor color: UIColor) -> Image {
        let rect = CGRect(origin: .zero, size: CGSize(width: 4, height: 4))

        UIGraphicsBeginImageContextWithOptions(rect.size, true, 1)
        defer {
            UIGraphicsEndImageContext()
        }

        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Could not create image")
            return UIImage()
        }
        return image
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
}
#endif
