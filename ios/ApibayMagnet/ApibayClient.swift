import Foundation

/// Talks to apibay directly. Native URLSession is not subject to CORS,
/// so no proxy/Worker is needed.
struct ApibayClient {
    enum ClientError: LocalizedError {
        case badResponse(Int)

        var errorDescription: String? {
            switch self {
            case .badResponse(let code):
                return "apibay returned HTTP \(code). Try again in a moment."
            }
        }
    }

    func search(query: String) async throws -> [Torrent] {
        var components = URLComponents(string: "https://apibay.org/q.php")!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.setValue("apibay-magnet-search", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ClientError.badResponse(http.statusCode)
        }

        let items = try JSONDecoder().decode([Torrent].self, from: data)
        // apibay returns [{"id":"0","name":"No results returned"}] when there are no hits.
        return items.filter { $0.id != "0" }
    }
}
