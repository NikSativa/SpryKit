import Foundation
import XCTest

@testable import NSpry

final class FriendlyStringConvertibleTests: XCTestCase {
    func test_friendle_description() {
        XCTAssertEqual(makeFriendlyDescription(for: nil, close: true), "<nil>")
        XCTAssertEqual(makeFriendlyDescription(for: nil, close: false), "nil")
        XCTAssertEqual(makeFriendlyDescription(for: 1, close: true), "<1>")
        XCTAssertEqual(makeFriendlyDescription(for: 1, close: false), "1")

        XCTAssertEqual(makeFriendlyDescription(for: [], separator: "---", closeEach: true), "<>")
        XCTAssertEqual(makeFriendlyDescription(for: [], separator: "-", closeEach: false), "<>")
        XCTAssertEqual(makeFriendlyDescription(for: [1, 2], separator: "|-|", closeEach: true), "<1>|-|<2>")
        XCTAssertEqual(makeFriendlyDescription(for: [1, 2], separator: "|-|", closeEach: false), "1|-|2")
    }
}
