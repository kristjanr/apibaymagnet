import Foundation

/// One apibay search result. apibay returns every field as a JSON string,
/// so we decode strings and expose typed values via computed properties.
struct Torrent: Codable, Identifiable {
    let id: String
    let name: String
    let infoHash: String
    let seeders: String
    let leechers: String
    let size: String
    let added: String

    enum CodingKeys: String, CodingKey {
        case id, name, seeders, leechers, size, added
        case infoHash = "info_hash"
    }

    var seedersInt: Int { Int(seeders) ?? 0 }
    var leechersInt: Int { Int(leechers) ?? 0 }
    var sizeBytes: Int64 { Int64(size) ?? 0 }

    var addedDate: Date? {
        guard let seconds = TimeInterval(added), seconds > 0 else { return nil }
        return Date(timeIntervalSince1970: seconds)
    }

    var magnetURL: String {
        Trackers.makeMagnet(infoHash: infoHash, name: name)
    }

    /// Bytes -> "1.23 GB" (ports `formatSize` from the web app).
    var formattedSize: String {
        let n = sizeBytes
        if n <= 0 { return "0 B" }
        let units = ["B", "KB", "MB", "GB", "TB"]
        let i = min(Int(log(Double(n)) / log(1024)), units.count - 1)
        let value = Double(n) / pow(1024, Double(i))
        return String(format: "%.2f %@", value, units[i])
    }

    /// Unix timestamp -> "YYYY-MM-DD", or nil when unavailable.
    var formattedDate: String? {
        guard let date = addedDate else { return nil }
        return Torrent.dateFormatter.string(from: date)
    }

    /// Best-effort file extension from the release name (ports `fileExt`).
    var fileExtension: String? {
        let lower = name.lowercased()
        guard let range = lower.range(of: "\\.([a-z0-9]{2,4})$", options: .regularExpression) else {
            return nil
        }
        return String(lower[range].dropFirst()) // drop the leading dot
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
