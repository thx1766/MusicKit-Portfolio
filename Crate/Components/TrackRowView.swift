import SwiftUI

/// Reusable row for displaying a song/track in a list.
/// Lightweight view body for scroll performance — no heavy computation.
struct TrackRowView: View {
    let song: SongItem
    let index: Int?
    let onTap: () -> Void

    init(song: SongItem, index: Int? = nil, onTap: @escaping () -> Void) {
        self.song = song
        self.index = index
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let index {
                    Text("\(index)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .center)
                }

                ArtworkImageView(
                    source: song.artworkURL,
                    width: 44,
                    height: 44,
                    cornerRadius: 6
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(song.artistName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let duration = song.duration {
                    Text(duration.formatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(song.title) by \(song.artistName)")
        .accessibilityHint("Double tap to play")
    }
}

// MARK: - Duration Formatting

private extension TimeInterval {
    var formatted: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    List {
        ForEach(Array(MockCatalogService.sampleSongs.prefix(5).enumerated()), id: \.element.id) { index, song in
            TrackRowView(song: song, index: index + 1) {}
        }
    }
    .environment(\.services, .preview)
}
