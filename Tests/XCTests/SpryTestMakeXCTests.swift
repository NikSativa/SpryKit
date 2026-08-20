import Foundation
import SpryKit
import XCTest

final class SpryTestMakeXCTests: XCTestCase {
    private struct Payload: Codable, Equatable {
        let name: String
        let age: Int
    }

    func test_url() {
        XCTAssertEqual(URL.spry.testMake(), URL(string: "http://www.some.com"))
        XCTAssertEqual(URL.spry.testMake("https://example.com/path"), URL(string: "https://example.com/path"))
    }

    func test_timeZone() {
        XCTAssertEqual(TimeZone.spry.testMake().secondsFromGMT(), 0)
        XCTAssertEqual(TimeZone.spry.testMake(secondsFromGMT: 3600).secondsFromGMT(), 3600)
    }

    func test_date() {
        let subject = Date.spry.testMake(year: 2026, month: 8, day: 20, hour: 12, minute: 30, second: 15)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .spry.testMake()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: subject)

        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 8)
        XCTAssertEqual(components.day, 20)
        XCTAssertEqual(components.hour, 12)
        XCTAssertEqual(components.minute, 30)
        XCTAssertEqual(components.second, 15)

        XCTAssertEqual(Date.spry.testMake(year: 2026, month: 8, day: 20), Date.spry.testMake(year: 2026, month: 8, day: 20))
        XCTAssertNotEqual(Date.spry.testMake(year: 2026, month: 8, day: 20), Date.spry.testMake(year: 2026, month: 8, day: 21))
    }

    func test_data_round_trip() throws {
        let payload = Payload(name: "John", age: 30)
        let encoded = try Data.spry.testMake(from: payload)

        XCTAssertEqual(try Data.spry.testMake(Payload.self, from: encoded), payload)

        let text = try XCTUnwrap(String(data: encoded, encoding: .utf8))
        XCTAssertTrue(text.contains("\"age\""))
        XCTAssertLessThan(try XCTUnwrap(text.range(of: "\"age\"")?.lowerBound), try XCTUnwrap(text.range(of: "\"name\"")?.lowerBound))
    }

    func test_data_decoding_failure() {
        XCTAssertThrowsError(try Data.spry.testMake(Payload.self, from: Data("not json".utf8)))
    }

    func test_urlRequest() {
        let byURL = URLRequest.spry.testMake(url: URL.spry.testMake("https://example.com"),
                                             headers: ["Key": "Value"])
        XCTAssertEqual(byURL.url, URL(string: "https://example.com"))
        XCTAssertEqual(byURL.allHTTPHeaderFields, ["Key": "Value"])

        let byString = URLRequest.spry.testMake(url: "https://example.com", headers: ["Key": "Value"])
        XCTAssertEqual(byString, byURL)

        XCTAssertEqual(URLRequest.spry.testMake().url, URL(string: "http://www.some.com"))
    }

    func test_urlRequest_friendly_description() {
        let subject = URLRequest.spry.testMake(url: "https://example.com", headers: ["Key": "Value"])
        let description = subject.friendlyDescription

        XCTAssertTrue(description.contains("URLRequest"))
        XCTAssertTrue(description.contains("https://example.com"))
        XCTAssertTrue(description.contains("Key"))
        XCTAssertTrue(description.contains("Value"))
    }

    func test_dispatchTime() {
        let now = DispatchTime.now()
        let future = DispatchTime.spry.testMake(secondsFromNow: 10)
        XCTAssertGreaterThan(future, now)

        guard case let .validator(isNear) = DispatchTime.spry.argument(secondsFromNow: 10) else {
            return XCTFail("expected a validator")
        }

        XCTAssertTrue(isNear(DispatchTime.spry.testMake(secondsFromNow: 10)))
        XCTAssertFalse(isNear(DispatchTime.spry.testMake(secondsFromNow: 20)))
        XCTAssertFalse(isNear("not a DispatchTime"))
        XCTAssertFalse(isNear(nil))
    }
}
