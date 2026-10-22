import XCTest
@testable import FitFlowCore

private final class StubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (Int, Data))?
    static func body(of request: URLRequest) throws -> Data {
        if let data = request.httpBody { return data }
        guard let stream = request.httpBodyStream else { throw AppError.message("Missing test request body") }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let capacity = 4096
        var buffer = [UInt8](repeating: 0, count: capacity)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: capacity)
            if count < 0 { throw stream.streamError ?? AppError.message("Cannot read test body") }
            if count == 0 { break }
            data.append(contentsOf: buffer.prefix(count))
        }
        return data
    }
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, data) = try Self.handler!(request)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: status,
                    httpVersion: nil, headerFields: ["Content-Type": "application/json"])!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}

final class GeminiTests: XCTestCase {
    private func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    @MainActor
    func testConsentAndPromptDataMinimization() async throws {
        let service = GeminiService()
        var profile = Fixtures.profile
        profile.allowsAIUpload = false
        XCTAssertThrowsError(try service.generateWorkoutAndMealPlan(profile: profile, startDate: Fixtures.start))
        profile.allowsAIUpload = true
        let prompt = try service.generateWorkoutAndMealPlan(profile: profile, startDate: Fixtures.start)
        XCTAssertFalse(prompt.contains(profile.name))
        XCTAssertFalse(prompt.contains("birthDate"))
        XCTAssertTrue(prompt.contains("food_preferences"))
        XCTAssertTrue(prompt.contains("takeaway_main_meals_per_day"))
    }

    @MainActor
    func testRESTRequestUsesHeaderAndStructuredOutput() async throws {
        let data = try Fixtures.data
        StubURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-goog-api-key"), "test-key")
            XCTAssertNil(request.url?.query)
            let body = try JSONSerialization.jsonObject(with: StubURLProtocol.body(of: request)) as! [String: Any]
            let config = body["generationConfig"] as! [String: Any]
            XCTAssertEqual(config["responseMimeType"] as? String, "application/json")
            XCTAssertNotNil(config["responseJsonSchema"])
            return (200, try JSONSerialization.data(withJSONObject: [
                "candidates": [["finishReason": "STOP", "content": ["parts": [["text": String(decoding: data, as: UTF8.self)]]]]]
            ]))
        }
        defer { StubURLProtocol.handler = nil }
        let session = session()
        defer { session.invalidateAndCancel() }
        let service = GeminiService(session: session, keyProvider: { "test-key" }, modelProvider: { "test-model" })
        let response = try await service.fetchWorkoutPlan(prompt: "test prompt")
        XCTAssertEqual(response.dailyPlan.count, 7)
    }

    @MainActor
    func testMissingKeyDoesNotMakeNetworkRequest() async throws {
        let session = session()
        defer { session.invalidateAndCancel() }
        StubURLProtocol.handler = { _ in XCTFail("No network request should be made"); return (200, Data()) }
        defer { StubURLProtocol.handler = nil }
        let service = GeminiService(session: session, keyProvider: { "" })
        do {
            _ = try await service.fetchWorkoutPlan(prompt: "test")
            XCTFail("Expected missing key error")
        } catch { XCTAssertTrue(error.localizedDescription.contains("API Key")) }
    }

    @MainActor
    func testRateLimitAndTruncatedResponseAreReported() async throws {
        let session = session()
        defer { session.invalidateAndCancel() }
        let service = GeminiService(session: session, keyProvider: { "test-key" })
        StubURLProtocol.handler = { _ in (429, Data("{}".utf8)) }
        defer { StubURLProtocol.handler = nil }
        do {
            _ = try await service.fetchWorkoutPlan(prompt: "test")
            XCTFail("Expected rate limit")
        } catch { XCTAssertTrue(error.localizedDescription.contains("额度")) }
        StubURLProtocol.handler = { _ in
            (200, Data(#"{"candidates":[{"finishReason":"MAX_TOKENS","content":{"parts":[{"text":"{}"}]}}]}"#.utf8))
        }
        do {
            _ = try await service.fetchWorkoutPlan(prompt: "test")
            XCTFail("Expected truncated response rejection")
        } catch { XCTAssertTrue(error.localizedDescription.contains("完整计划")) }
    }
}
