//
//  StubURLProtocol.swift
//  ArmonyIntegrationTests
//
//  Created by Koray Yıldız on 14.11.26.
//

import Foundation

/// Answers requests of a `URLSession` with registered stubs instead of hitting the network.
///
/// Register it through `URLSessionConfiguration.stubbed()` and add stubs per method + path:
/// ```swift
/// StubURLProtocol.stub(.post, path: "/auth/refresh", statusCode: 401, body: errorData)
/// StubURLProtocol.stub(.post, path: "/auth/refresh", body: tokenData)
/// ```
/// Multiple stubs for the same method + path are returned in order; the last one keeps answering.
/// A request without a matching stub fails with `URLError(.resourceUnavailable)` and is still recorded.
final class StubURLProtocol: URLProtocol {

    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    enum Response {
        case http(statusCode: Int, headers: [String: String], body: Data?)
        case failure(Error)
    }

    struct RecordedRequest {
        let request: URLRequest
        let body: Data?

        var method: String? {
            return request.httpMethod
        }

        var path: String? {
            return request.url?.path
        }

        func value(forHTTPHeaderField field: String) -> String? {
            return request.value(forHTTPHeaderField: field)
        }
    }

    private final class Entry {
        let method: Method
        let path: String
        var responses: [Response]

        init(method: Method, path: String, response: Response) {
            self.method = method
            self.path = path
            self.responses = [response]
        }

        func matches(_ request: URLRequest) -> Bool {
            guard request.httpMethod == method.rawValue, let requestPath = request.url?.path else {
                return false
            }
            return requestPath.hasSuffix(path)
        }

        func nextResponse() -> Response {
            return responses.count > 1 ? responses.removeFirst() : responses[0]
        }
    }

    private static let lock = NSLock()
    private static var entries: [Entry] = []
    private static var requests: [RecordedRequest] = []

    // MARK: - Stubbing

    /// - Parameter path: Matched as a suffix of the request path, so the API version prefix can be omitted.
    static func stub(_ method: Method = .get,
                     path: String,
                     statusCode: Int = 200,
                     headers: [String: String] = ["Content-Type": "application/json"],
                     body: Data?) {
        add(.http(statusCode: statusCode, headers: headers, body: body), method: method, path: path)
    }

    static func stub(_ method: Method = .get, path: String, error: Error) {
        add(.failure(error), method: method, path: path)
    }

    static var recordedRequests: [RecordedRequest] {
        return synchronized { requests }
    }

    static func recordedRequests(_ method: Method, path: String) -> [RecordedRequest] {
        return recordedRequests.filter { $0.method == method.rawValue && ($0.path ?? "").hasSuffix(path) }
    }

    static func reset() {
        synchronized {
            entries.removeAll()
            requests.removeAll()
        }
    }

    private static func add(_ response: Response, method: Method, path: String) {
        synchronized {
            if let entry = entries.first(where: { $0.method == method && $0.path == path }) {
                entry.responses.append(response)
            }
            else {
                entries.append(Entry(method: method, path: path, response: response))
            }
        }
    }

    private static func synchronized<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let response: Response? = Self.synchronized {
            Self.requests.append(RecordedRequest(request: request, body: request.bodyData))
            return Self.entries.first(where: { $0.matches(request) })?.nextResponse()
        }

        switch response {
        case let .http(statusCode, headers, body):
            guard let url = request.url,
                  let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badURL))
                return
            }
            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            if let body = body {
                client?.urlProtocol(self, didLoad: body)
            }
            client?.urlProtocolDidFinishLoading(self)

        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)

        case .none:
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
        }
    }

    override func stopLoading() { }
}

// MARK: - URLSessionConfiguration
extension URLSessionConfiguration {

    /// Ephemeral configuration whose requests are answered only by `StubURLProtocol`.
    static func stubbed() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return configuration
    }
}

// MARK: - URLRequest
private extension URLRequest {

    /// `URLSession` moves `httpBody` into `httpBodyStream` before handing the request to a `URLProtocol`.
    var bodyData: Data? {
        if let httpBody = httpBody {
            return httpBody
        }

        guard let stream = httpBodyStream else {
            return nil
        }

        stream.open()
        defer { stream.close() }

        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while stream.hasBytesAvailable {
            let readCount = stream.read(buffer, maxLength: bufferSize)
            guard readCount > 0 else { break }
            data.append(buffer, count: readCount)
        }
        return data
    }
}
