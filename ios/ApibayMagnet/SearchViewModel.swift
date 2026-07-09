import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Torrent] = []
    @Published var sort: SortOption = .seedersDesc
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasSearched = false

    private let client = ApibayClient()

    /// Re-sorts in memory whenever `sort` changes — no refetch (same UX as the web app).
    var sortedResults: [Torrent] {
        results.sorted(by: sort.comparator)
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        hasSearched = true
        defer { isLoading = false }

        do {
            results = try await client.search(query: trimmed)
        } catch {
            results = []
            errorMessage = error.localizedDescription
        }
    }
}
