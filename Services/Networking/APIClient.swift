import Foundation

final class APIClient {
    enum Method: String { case GET, POST, PUT, PATCH, DELETE }

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = NetworkCoders.decoder,
        encoder: JSONEncoder = NetworkCoders.encoder
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func request<T: Decodable>(
        _ type: T.Type,
        _ path: String,
        method: Method = .GET,
        token: String? = nil,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil
    ) async throws -> T {
        let trimmed = path.trimmingCharacters(in: .init(charactersIn: "/"))

        let url: URL
        if trimmed.contains("?") {
            guard let fullURL = URL(string: trimmed, relativeTo: baseURL) else {
                throw URLError(.badURL)
            }
            url = fullURL
        } else {
            var tmp = baseURL
            tmp.append(path: trimmed)
            url = tmp
        }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue

        if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(T.self, from: data)
    }

}

private struct AnyEncodable: Encodable {
    private let enc: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { self.enc = wrapped.encode }
    func encode(to encoder: Encoder) throws { try enc(encoder) }
}
