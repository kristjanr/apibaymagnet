import SwiftUI

struct ContentView: View {
    @StateObject private var vm = SearchViewModel()
    @State private var toast: String?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Apibay")
                .searchable(text: $vm.query, prompt: "Search torrents")
                .onSubmit(of: .search) {
                    Task { await vm.search() }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortMenu
                    }
                }
                .overlay(alignment: .bottom) {
                    if let toast {
                        Text(toast)
                            .font(.callout.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 12)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            ProgressView("Searching…")
        } else if let error = vm.errorMessage {
            ContentUnavailableView {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") { Task { await vm.search() } }
            }
        } else if vm.results.isEmpty && vm.hasSearched {
            ContentUnavailableView.search
        } else if vm.results.isEmpty {
            ContentUnavailableView {
                Label("Search apibay", systemImage: "magnifyingglass")
            } description: {
                Text("Enter a search term to find torrents.")
            }
        } else {
            resultsList
        }
    }

    private var resultsList: some View {
        List(vm.sortedResults) { torrent in
            TorrentRow(torrent: torrent)
                .contentShape(Rectangle())
                .onTapGesture { copy(torrent) }
                .swipeActions(edge: .trailing) {
                    ShareLink(item: torrent.magnetURL) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
        }
        .listStyle(.plain)
        .refreshable { await vm.search() }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort", selection: $vm.sort) {
                ForEach(SortOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }

    private func copy(_ torrent: Torrent) {
        UIPasteboard.general.string = torrent.magnetURL
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation { toast = "Magnet copied" }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { if toast == "Magnet copied" { toast = nil } }
        }
    }
}
