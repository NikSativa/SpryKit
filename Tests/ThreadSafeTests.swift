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
        let storage = Storage()

        for i in 0..<100 {
            let exp = expectation(description: "ThreadSafe[\(i)]")
            expectetions.append(exp)

            let queue: DispatchQueue = Bool.random() ? .global(qos: .utility) : .global(qos: .background)
            queue.asyncAfter(deadline: .now() + 0.1) {
                mutex.sync {
                    let v = threadSafe.getAString()
                    storage.values.append(v)
                }
                exp.fulfill()
            }
        }

        wait(for: expectetions, timeout: 5)
        XCTAssertEqual(storage.values.count, expectetions.count)
    }
}

private final class Storage: @unchecked Sendable {
    var values: [String] = []
}
