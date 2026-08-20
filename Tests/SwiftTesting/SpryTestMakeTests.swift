#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Spry TestMake Tests", .serialized)
struct SpryTestMakeTests {
    private struct Payload: Codable, Equatable {
        let name: String
        let age: Int
    }

    @Test("URL")
    func url() {
        #expect(URL.spry.testMake() == URL(string: "http://www.some.com"))
        #expect(URL.spry.testMake("https://example.com/path") == URL(string: "https://example.com/path"))
    }

    @Test("TimeZone")
    func timeZone() {
        #expect(TimeZone.spry.testMake().secondsFromGMT() == 0)
        #expect(TimeZone.spry.testMake(secondsFromGMT: 3600).secondsFromGMT() == 3600)
    }

    @Test("Date")
    func date() {
        let subject = Date.spry.testMake(year: 2026, month: 8, day: 20, hour: 12, minute: 30, second: 15)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .spry.testMake()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: subject)

        #expect(components.year == 2026)
        #expect(components.month == 8)
        #expect(components.day == 20)
        #expect(components.hour == 12)
        #expect(components.minute == 30)
        #expect(components.second == 15)

        #expect(Date.spry.testMake(year: 2026, month: 8, day: 20) == Date.spry.testMake(year: 2026, month: 8, day: 20))
        #expect(Date.spry.testMake(year: 2026, month: 8, day: 20) != Date.spry.testMake(year: 2026, month: 8, day: 21))
    }

    @Test("Data round trip")
    func data() throws {
        let payload = Payload(name: "John", age: 30)
        let encoded = try Data.spry.testMake(from: payload)

        #expect(try Data.spry.testMake(Payload.self, from: encoded) == payload)

        let text = try #require(String(data: encoded, encoding: .utf8))
        #expect(text.contains("\"age\""))
        #expect(text.range(of: "\"age\"")!.lowerBound < text.range(of: "\"name\"")!.lowerBound)
    }

    @Test("Data decoding failure")
    func dataDecodingFailure() {
        #expect(throws: (any Error).self) {
            try Data.spry.testMake(Payload.self, from: Data("not json".utf8))
        }
    }

    @Test("URLRequest")
    func urlRequest() {
        let byURL = URLRequest.spry.testMake(url: URL.spry.testMake("https://example.com"),
                                             headers: ["Key": "Value"])
        #expect(byURL.url == URL(string: "https://example.com"))
        #expect(byURL.allHTTPHeaderFields == ["Key": "Value"])

        let byString = URLRequest.spry.testMake(url: "https://example.com", headers: ["Key": "Value"])
        #expect(byString == byURL)

        #expect(URLRequest.spry.testMake().url == URL(string: "http://www.some.com"))
    }

    @Test("URLRequest friendly description")
    func urlRequestFriendlyDescription() {
        let subject = URLRequest.spry.testMake(url: "https://example.com", headers: ["Key": "Value"])
        let description = subject.friendlyDescription

        #expect(description.contains("URLRequest"))
        #expect(description.contains("https://example.com"))
        #expect(description.contains("Key"))
        #expect(description.contains("Value"))
    }

    @Test("DispatchTime")
    func dispatchTime() {
        let now = DispatchTime.now()
        let future = DispatchTime.spry.testMake(secondsFromNow: 10)
        #expect(future > now)

        guard case let .validator(isNear) = DispatchTime.spry.argument(secondsFromNow: 10) else {
            Issue.record("expected a validator")
            return
        }

        #expect(isNear(DispatchTime.spry.testMake(secondsFromNow: 10)))
        #expect(!isNear(DispatchTime.spry.testMake(secondsFromNow: 20)))
        #expect(!isNear("not a DispatchTime"))
        #expect(!isNear(nil))
    }
}
#endif // canImport(Testing)
