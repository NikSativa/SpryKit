import Foundation
import XCTest
@testable import SpryKit

final class DidCallResultXCTests: XCTestCase {
    func test_each_description_uses_its_own_source() {
        let subject = DidCallResult(success: true,
                                    description: "plain",
                                    debugDescription: "debug",
                                    friendlyDescription: "friendly")

        XCTAssertTrue(subject.success)
        XCTAssertEqual(subject.description, "plain")
        XCTAssertEqual(subject.debugDescription, "debug")
        XCTAssertEqual(subject.friendlyDescription, "friendly")
    }

    func test_descriptions_are_evaluated_lazily_and_only_once() {
        let counter = CallCounter()
        let subject = DidCallResult(success: false,
                                    description: counter.next(),
                                    debugDescription: "debug",
                                    friendlyDescription: "friendly")

        XCTAssertEqual(counter.count, 0)
        XCTAssertEqual(subject.description, "1")
        XCTAssertEqual(subject.description, "1")
        XCTAssertEqual(counter.count, 1)
    }
}

private final class CallCounter {
    private(set) var count: Int = 0

    func next() -> String {
        count += 1
        return "\(count)"
    }
}
