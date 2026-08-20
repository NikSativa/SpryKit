import Foundation
import SpryKit
import XCTest

final class ThreadSafeXCTests: XCTestCase {
    func test_threadSafe() {
        let threadSafe: SpryableTestClass = .init()
        threadSafe.stub(.getAString).andReturn("Hello, World!")

        var expectetions: [XCTestExpectation] = []
        let storage = Storage()

        for i in 0..<100 {
            let exp = expectation(description: "ThreadSafe[\(i)]")
            expectetions.append(exp)

            let queue: DispatchQueue = Bool.random() ? .global(qos: .utility) : .global(qos: .background)
            queue.asyncAfter(deadline: .now() + 0.1) {
                storage.append(threadSafe.getAString())
                exp.fulfill()
            }
        }

        wait(for: expectetions, timeout: 10)
        XCTAssertEqual(storage.values.count, expectetions.count)
        XCTAssertEqual(threadSafe.recordedCallsCount, expectetions.count)
    }
}

private final class Storage: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String] = []

    var values: [String] {
        lock.lock()
        defer {
            lock.unlock()
        }

        return storage
    }

    func append(_ value: String) {
        lock.lock()
        defer {
            lock.unlock()
        }

        storage.append(value)
    }
}
