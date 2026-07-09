import SwiftUI

struct TorrentRow: View {
    let torrent: Torrent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(torrent.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(3)

            HStack(spacing: 12) {
                Label("\(torrent.seedersInt)", systemImage: "arrow.up")
                    .foregroundStyle(.green)
                Label("\(torrent.leechersInt)", systemImage: "arrow.down")
                    .foregroundStyle(.red)
                Text(torrent.formattedSize)
                    .foregroundStyle(.secondary)
                if let date = torrent.formattedDate {
                    Text(date)
                        .foregroundStyle(.secondary)
                }
                if let ext = torrent.fileExtension {
                    Text(ext.uppercased())
                        .foregroundStyle(.purple)
                }
            }
            .font(.caption)
            .labelStyle(.titleAndIcon)
        }
        .padding(.vertical, 4)
    }
}
