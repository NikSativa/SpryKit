import Foundation

// MARK: - URLRequest.spry

public extension URLRequest {
    enum spry {
        // namespace
    }
}

public extension URLRequest.spry {
    static func testMake(url: String,
                         headers: [String: String] = [:]) -> URLRequest {
        return testMake(url: .spry.testMake(url),
                        headers: headers)
    }

    static func testMake(url: URL = .spry.testMake(),
                         headers: [String: String] = [:]) -> URLRequest {
        var request = URLRequest(url: url)
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

// MARK: - URLRequest + SpryFriendlyStringConvertible

extension URLRequest: SpryFriendlyStringConvertible {
    public var friendlyDescription: String {
        return [
            String(describing: type(of: self)),
            description,
            String(describing: allHTTPHeaderFields)
        ]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
