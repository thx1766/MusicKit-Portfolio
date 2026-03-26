import SwiftUI

/// Generic horizontal scrolling shelf used on the Browse screen.
/// Supports large (album art) and compact (song) shelf styles.
/// Uses LazyHStack for efficient rendering of off-screen items.
struct ShelfView<Item: Identifiable & Hashable, Content: View>: View {
    let title: String
    let items: [Item]
    let style: ShelfStyle
    let routeForItem: (Item) -> Route
    @ViewBuilder let content: (Item) -> Content

    @Environment(Router.self) private var router

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: style.spacing) {
                    ForEach(items) { item in
                        Button {
                            router.navigate(to: routeForItem(item))
                        } label: {
                            content(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

// MARK: - Shelf Style

enum ShelfStyle {
    case large    // 160×160 artwork cards (albums, playlists)
    case compact  // Smaller cards for songs

    var spacing: CGFloat {
        switch self {
        case .large: return 16
        case .compact: return 12
        }
    }
}

// MARK: - Album Shelf Item

struct AlbumShelfItemView: View {
    let album: AlbumItem
    private let size: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ArtworkImageView(
                source: album.artworkURL,
                width: size,
                height: size,
                cornerRadius: 8
            )

            Text(album.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(album.artistName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: size)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(album.title) by \(album.artistName)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Playlist Shelf Item

struct PlaylistShelfItemView: View {
    let playlist: PlaylistItem
    private let size: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ArtworkImageView(
                source: playlist.artworkURL,
                width: size,
                height: size,
                cornerRadius: 8
            )

            Text(playlist.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(playlist.curatorName ?? "")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: size)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(playlist.name)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Song Shelf Item

struct SongShelfItemView: View {
    let song: SongItem
    private let size: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ArtworkImageView(
                source: song.artworkURL,
                width: size,
                height: size,
                cornerRadius: 8
            )

            Text(song.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(song.artistName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: size)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(song.title) by \(song.artistName)")
        .accessibilityAddTraits(.isButton)
    }
}
