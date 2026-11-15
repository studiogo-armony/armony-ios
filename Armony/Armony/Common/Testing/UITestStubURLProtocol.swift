//
//  UITestStubURLProtocol.swift
//  Armony
//

#if DEBUG
import Foundation

/// Answers the app's requests with the `UITestStub`s a UI test wrote to `UITestLaunchEnvironment.stubsFile`
/// and appends every request to `UITestLaunchEnvironment.requestLogFile`, so tests can assert what the app sent.
/// A request without a matching stub fails, like an unreachable server.
final class UITestStubURLProtocol: URLProtocol {

    private static let stubs: [UITestStub] = {
        let environment = ProcessInfo.processInfo.environment
        guard let path = environment[UITestLaunchEnvironment.stubsFile],
              let data = FileManager.default.contents(atPath: path),
              let stubs = try? JSONDecoder().decode([UITestStub].self, from: data) else {
            return []
        }
        return stubs
    }()

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let stub = Self.stubs.first(where: { $0.matches(request) })
        UITestRequestLog.append(request, isStubbed: stub != nil)

        guard let url = request.url,
              let stub,
              let response = HTTPURLResponse(
                url: url,
                statusCode: stub.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
              ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(stub.body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}

private extension UITestStub {

    func matches(_ request: URLRequest) -> Bool {
        guard request.httpMethod == method, let requestPath = request.url?.path else {
            return false
        }
        return requestPath.hasSuffix(path)
    }
}

// MARK: - UITestRequestLog
private enum UITestRequestLog {

    private static let lock = NSLock()

    static func append(_ request: URLRequest, isStubbed: Bool) {
        guard let path = ProcessInfo.processInfo.environment[UITestLaunchEnvironment.requestLogFile],
              let method = request.httpMethod,
              let requestPath = request.url?.path else {
            return
        }

        let recorded = UITestRecordedRequest(
            method: method,
            path: requestPath,
            body: request.bodyData.map { String(decoding: $0, as: UTF8.self) },
            isStubbed: isStubbed
        )
        guard var line = try? JSONEncoder().encode(recorded) else { return }
        line.append(0x0A)

        lock.lock()
        defer { lock.unlock() }
        guard let handle = FileHandle(forWritingAtPath: path) else { return }
        handle.seekToEndOfFile()
        handle.write(line)
        handle.closeFile()
    }
}

private extension URLRequest {

    /// `URLSession` moves `httpBody` into `httpBodyStream` before handing the request to a `URLProtocol`.
    var bodyData: Data? {
        if let httpBody { return httpBody }
        guard let stream = httpBodyStream else { return nil }

        stream.open()
        defer { stream.close() }

        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
#endif
