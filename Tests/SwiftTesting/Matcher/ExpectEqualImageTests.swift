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

    @Test("Reversed argument order")
    func reversed_argument_order() {
        // A message is required here: without it the trailing closure could bind to either overload.
        expectEqualImage({ Image.spry.testImage }, "expected image") {
            Image.spry.testImage
        }

        expectNotEqualImage({ Image.spry.testImage2 }, "expected a different image") {
            Image.spry.testImage
        }
    }

    @Test("A nil image is reported")
    func a_nil_image_is_reported() {
        withKnownIssue {
            expectEqualImage({ nil }, { Image.spry.testImage })
        } matching: { issue in
            issue.description.contains("First image is nil")
        }

        withKnownIssue {
            expectEqualImage({ Image.spry.testImage }, { nil })
        } matching: { issue in
            issue.description.contains("Second image is nil")
        }

        withKnownIssue {
            expectNotEqualImage({ nil }, { Image.spry.testImage })
        } matching: { issue in
            issue.description.contains("First image is nil")
        }

        withKnownIssue {
            expectNotEqualImage({ Image.spry.testImage }, { nil })
        } matching: { issue in
            issue.description.contains("Second image is nil")
        }
    }

    @Test("A thrown error is reported")
    func a_thrown_error_is_reported() {
        withKnownIssue {
            expectEqualImage({ throw ImageTestError.broken }, { Image.spry.testImage })
        } matching: { issue in
            issue.description.contains("The operation couldn") || issue.description.contains("broken")
        }

        withKnownIssue {
            expectNotEqualImage({ throw ImageTestError.broken }, { Image.spry.testImage })
        } matching: { issue in
            issue.description.contains("The operation couldn") || issue.description.contains("broken")
        }
    }

    @Test("Unequal images are reported")
    func unequal_images_are_reported() {
        withKnownIssue("images differ") {
            expectEqualImage({ Image.spry.testImage }, { Image.spry.testImage2 })
        }

        withKnownIssue("images match") {
            expectNotEqualImage({ Image.spry.testImage }, { Image.spry.testImage })
        }
    }
}

private enum ImageTestError: Error {
    case broken
}
#endif // canImport(Testing)
