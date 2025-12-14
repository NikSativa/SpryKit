#if canImport(Testing)
import Foundation
import Testing
@testable import SpryKit

@Suite("FriendlyStringConvertible Tests", .serialized)
struct FriendlyStringConvertibleTests {
    @Test("Friendly description")
    func friendle_description() {
        #expect(makeFriendlyDescription(for: nil, close: true) == "<nil>")
        #expect(makeFriendlyDescription(for: nil, close: false) == "nil")
        #expect(makeFriendlyDescription(for: 1, close: true) == "<1>")
        #expect(makeFriendlyDescription(for: 1, close: false) == "1")

        #expect(makeFriendlyDescription(for: [], separator: "---", closeEach: true) == "<>")
        #expect(makeFriendlyDescription(for: [], separator: "-", closeEach: false) == "<>")
        #expect(makeFriendlyDescription(for: [1, 2], separator: "|-|", closeEach: true) == "<1>|-|<2>")
        #expect(makeFriendlyDescription(for: [1, 2], separator: "|-|", closeEach: false) == "1|-|2")
    }
}
#endif // canImport(Testing)
