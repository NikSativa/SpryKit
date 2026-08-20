#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ThreadSafe Tests", .serialized)
struct ThreadSafeTests {
    @Test("Thread safe")
    func threadSafe() async {
        let threadSafe: SpryableTestClass = .init()
        threadSafe.stub(.getAString).andReturn("Hello, World!")

        let values = await withTaskGroup(of: String.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    return threadSafe.getAString()
                }
            }

            var collected: [String] = []
            for await value in group {
                collected.append(value)
            }
            return collected
        }

        #expect(values.count == 100)
        #expect(values.allSatisfy { $0 == "Hello, World!" })
        #expect(threadSafe.recordedCallsCount == 100)
    }
}
#endif // canImport(Testing)
