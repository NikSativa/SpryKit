import Foundation
import XCTest

// PThread is internal
@testable import SpryKit

final class ThreadSafeTests: XCTestCase {
    func test_threadSafe() {
        let threadSafe: SpryableTestClass = .init()
        threadSafe.stub(.getAString).andReturn("Hello, World!")

        let mutex = PThread(kind: .recursive)
        var expectetions: [XCTestExpectation] = []
        var values: [String] = []

        for i in 0..<1000 {
            let exp = expectation(description: "ThreadSafe[\(i)]")
            expectetions.append(exp)

            let queue: DispatchQueue = Bool.random() ? .global(qos: .utility) : .global(qos: .background)
            queue.asyncAfter(deadline: .now() + 0.1) {
                mutex.sync {
                    values.append(threadSafe.getAString())
                }
                exp.fulfill()
            }
        }

        wait(for: expectetions, timeout: 1)
        XCTAssertEqual(values.count, expectetions.count)
    }
}
