import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
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
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        return pngData()
        #else
        #error("unsupported os")
        #endif
    }
}

public extension Image.spry {
    #if os(macOS)
    static let testImage: Image = .init(systemSymbolName: "circle", accessibilityDescription: nil)!
    static let testImage1: Image = .init(systemSymbolName: "square", accessibilityDescription: nil)!
    static let testImage2: Image = .init(systemSymbolName: "diamond", accessibilityDescription: nil)!
    static let testImage3: Image = .init(systemSymbolName: "octagon", accessibilityDescription: nil)!
    static let testImage4: Image = .init(systemSymbolName: "oval", accessibilityDescription: nil)!
    #elseif os(iOS) || os(tvOS) || os(watchOS)
    static let testImage: Image = .init(systemName: "circle")!
    static let testImage1: Image = .init(systemName: "square")!
    static let testImage2: Image = .init(systemName: "diamond")!
    static let testImage3: Image = .init(systemName: "octagon")!
    static let testImage4: Image = .init(systemName: "oval")!
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
