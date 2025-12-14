#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ExpectEqualImage Tests", .serialized)
struct ExpectEqualImageTests {
    @Test("Images")
    func images() {
        expectEqualImage({ Image.spry.testImage }, { Image.spry.testImage })
        expectNotEqualImage({ Image.spry.testImage }, { Image.spry.testImage2 })

        expectEqualImage({ Image.spry.testImage }, { Image.spry.testImage })

        expectNotEqualImage({ Image.spry.testImage }, { Image.spry.testImage2 })
    }
}
#endif // canImport(Testing)
