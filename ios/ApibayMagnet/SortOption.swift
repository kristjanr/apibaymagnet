import Foundation

/// Sort choices, mirroring the web app's dropdown. Default is `.seedersDesc`.
enum SortOption: String, CaseIterable, Identifiable {
    case seedersDesc, seedersAsc
    case leechersDesc, leechersAsc
    case sizeDesc, sizeAsc
    case dateNewest, dateOldest
    case nameAZ, nameZA
    case fileExtension

    var id: String { rawValue }

    var label: String {
        switch self {
        case .seedersDesc:   return "Seeders — most first"
        case .seedersAsc:    return "Seeders — fewest first"
        case .leechersDesc:  return "Leechers — most first"
        case .leechersAsc:   return "Leechers — fewest first"
        case .sizeDesc:      return "Size — largest first"
        case .sizeAsc:       return "Size — smallest first"
        case .dateNewest:    return "Date — newest first"
        case .dateOldest:    return "Date — oldest first"
        case .nameAZ:        return "Name — A to Z"
        case .nameZA:        return "Name — Z to A"
        case .fileExtension: return "File extension"
        }
    }

    var comparator: (Torrent, Torrent) -> Bool {
        switch self {
        case .seedersDesc:  return { $0.seedersInt > $1.seedersInt }
        case .seedersAsc:   return { $0.seedersInt < $1.seedersInt }
        case .leechersDesc: return { $0.leechersInt > $1.leechersInt }
        case .leechersAsc:  return { $0.leechersInt < $1.leechersInt }
        case .sizeDesc:     return { $0.sizeBytes > $1.sizeBytes }
        case .sizeAsc:      return { $0.sizeBytes < $1.sizeBytes }
        case .dateNewest:   return { ($0.addedDate ?? .distantPast) > ($1.addedDate ?? .distantPast) }
        case .dateOldest:   return { ($0.addedDate ?? .distantPast) < ($1.addedDate ?? .distantPast) }
        case .nameAZ:       return { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameZA:       return { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .fileExtension:
            // Group by extension; within a group keep seeders high-to-low (matches web app).
            return { a, b in
                let ea = a.fileExtension ?? ""
                let eb = b.fileExtension ?? ""
                if ea == eb { return a.seedersInt > b.seedersInt }
                return ea < eb
            }
        }
    }
}
