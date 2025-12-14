import Foundation

#if os(macOS)
import Cocoa

public typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS) || supportsVisionOS
import UIKit

public typealias Image = UIImage
#endif

// MARK: - Image.spry

public extension Image {
    enum spry: @unchecked Sendable {
        // namespace
    }

    func testData() -> Data? {
        #if os(macOS)
        return png
        #elseif os(iOS) || os(tvOS) || os(watchOS) || supportsVisionOS
        return pngData()
        #endif
    }
}

public extension Image.spry {
    #if os(macOS) && swift(>=6.2)
    static let testImage: Image = .init(systemSymbolName: "circle", accessibilityDescription: nil)!
    static let testImage1: Image = .init(systemSymbolName: "square", accessibilityDescription: nil)!
    static let testImage2: Image = .init(systemSymbolName: "diamond", accessibilityDescription: nil)!
    static let testImage3: Image = .init(systemSymbolName: "octagon", accessibilityDescription: nil)!
    static let testImage4: Image = .init(systemSymbolName: "oval", accessibilityDescription: nil)!
    #elseif os(macOS) && swift(>=6.0)
    nonisolated(unsafe) static let testImage: Image = .init(systemSymbolName: "circle", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage1: Image = .init(systemSymbolName: "square", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage2: Image = .init(systemSymbolName: "diamond", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage3: Image = .init(systemSymbolName: "octagon", accessibilityDescription: nil)!
    nonisolated(unsafe) static let testImage4: Image = .init(systemSymbolName: "oval", accessibilityDescription: nil)!
    #elseif os(macOS)
    static let testImage: Image = .init(systemSymbolName: "circle", accessibilityDescription: nil)!
    static let testImage1: Image = .init(systemSymbolName: "square", accessibilityDescription: nil)!
    static let testImage2: Image = .init(systemSymbolName: "diamond", accessibilityDescription: nil)!
    static let testImage3: Image = .init(systemSymbolName: "octagon", accessibilityDescription: nil)!
    static let testImage4: Image = .init(systemSymbolName: "oval", accessibilityDescription: nil)!
    #elseif os(watchOS)
    static let testImage: Image = .init(systemName: "circle")!
    static let testImage1: Image = .init(systemName: "square")!
    static let testImage2: Image = .init(systemName: "diamond")!
    static let testImage3: Image = .init(systemName: "octagon")!
    static let testImage4: Image = .init(systemName: "oval")!
    #elseif os(iOS) || os(tvOS) || supportsVisionOS
    static let testImage: Image = Self.image(withColor: .blue)
    static let testImage1: Image = Self.image(withColor: .green)
    static let testImage2: Image = Self.image(withColor: .red)
    static let testImage3: Image = Self.image(withColor: .black)
    static let testImage4: Image = Self.image(withColor: .white)

    private static func image(withColor color: UIColor) -> Image {
        let rect = CGRect(origin: .zero, size: CGSize(width: 4, height: 4))
        #if os(iOS) || os(tvOS)
        return UIGraphicsImageRenderer(bounds: rect).image { context in
            color.setFill()
            context.fill(rect)
        }
        #elseif supportsVisionOS
        let data = UIGraphicsImageRenderer(bounds: rect).pngData { context in
            color.setFill()
            context.fill(rect)
        }
        return Image(data: data)!
        #endif
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
}
#endif
