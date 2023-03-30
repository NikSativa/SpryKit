import Foundation

@testable import NSpry

extension Image {
    #if os(macOS)
    static let testImage: Image = .init(systemSymbolName: "circle", accessibilityDescription: nil)!
    static let testImage: Image = .init(systemSymbolName: "square", accessibilityDescription: nil)!
    #elseif os(iOS) || os(tvOS) || os(watchOS)
    static let testImage: Image = .init(systemName: "circle")!
    static let testImage2: Image = .init(systemName: "square")!
    #else
    #error("unsupported os")
    #endif
}
