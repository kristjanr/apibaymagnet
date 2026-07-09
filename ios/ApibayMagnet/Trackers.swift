import Foundation

extension String {
    /// Mimics JavaScript's `encodeURIComponent` so magnet links match the web app.
    func percentEncodedComponent() -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.!~*'()")
        return addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }
}

/// The tracker list appended to every magnet link (same set as the web app).
enum Trackers {
    static let list: [String] = [
        "udp://tracker.opentrackr.org:1337",
        "udp://open.stealth.si:80/announce",
        "udp://tracker.torrent.eu.org:451/announce",
        "udp://tracker.bittor.pw:1337/announce",
        "udp://public.popcorn-tracker.org:6969/announce",
        "udp://tracker.dler.org:6969/announce",
        "udp://exodus.desync.com:6969",
        "udp://open.demonii.com:1337/announce",
        "udp://glotorrents.pw:6969/announce",
        "udp://p4p.arenabg.com:1337",
        "udp://tracker.internetwarriors.net:1337",
    ]

    /// Builds `magnet:?xt=urn:btih:<hash>&dn=<name>&tr=...` (matches `index.html`).
    static func makeMagnet(infoHash: String, name: String) -> String {
        var magnet = "magnet:?xt=urn:btih:\(infoHash)&dn=\(name.percentEncodedComponent())"
        for tracker in list {
            magnet += "&tr=\(tracker.percentEncodedComponent())"
        }
        return magnet
    }
}
