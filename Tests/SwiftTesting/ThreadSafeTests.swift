#if canImport(Testing)
import Foundation
import Testing
import Threading

// PThread is internal
@testable import SpryKit

@Suite("ThreadSafe Tests", .serialized)
struct ThreadSafeTests {
    @Test("Thread safe")
    func threadSafe() async {
        let threadSafe: SpryableTestClass = .init()
        threadSafe.stub(.getAString).andReturn("Hello, World!")

        let mutex = PThread(kind: .recursive)
        let storage = Storage()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    mutex.sync {
                        let v = threadSafe.getAString()
                        storage.values.append(v)
                    }
                }
            }
        }

        #expect(storage.values.count == 100)
    }
}

private final class Storage: @unchecked Sendable {
    var values: [String] = []
}
#endif // canImport(Testing)
