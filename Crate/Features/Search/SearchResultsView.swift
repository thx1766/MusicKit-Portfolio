import SwiftUI

/// Displays categorized search results (songs, albums, artists, playlists).
/// Each category appears as a section with navigation to detail views.
struct SearchResultsView: View {
    let results: SearchResults

    @Environment(\.services) private var services
    @Environment(Router.self) private var router

    var body: some View {
        // Artists
        if !results.artists.isEmpty {
            Section("Artists") {
                ForEach(results.artists) { artist in
                    Button {
                        router.navigate(to: .artist(id: artist.id))
                    } label: {
                        artistRow(artist)
                    }
                    .buttonStyle(.plain)
                }
            }
        }

        // Albums
        if !results.albums.isEmpty {
            Section("Albums") {
                ForEach(results.albums) { album in
                    Button {
                        router.navigate(to: .album(id: album.id))
                    } label: {
                        albumRow(album)
                    }
                    .buttonStyle(.plain)
                }
            }
        }

        // Songs
        if !results.songs.isEmpty {
            Section("Songs") {
                ForEach(results.songs) { song in
                    TrackRowView(song: song) {
                        Task {
                            try? await services.player.play(song: song)
                        }
                    }
                }
            }
        }

        // Playlists
        if !results.playlists.isEmpty {
            Section("Playlists") {
                ForEach(results.playlists) { playlist in
                    Button {
                        router.navigate(to: .playlist(id: playlist.id))
                    } label: {
                        playlistRow(playlist)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Row Views

    private func artistRow(_ artist: ArtistItem) -> some View {
        HStack(spacing: 12) {
            ArtworkImageView(
                source: artist.artworkURL,
                width: 48,
                height: 48,
                cornerRadius: 24 // Circular
            )

            Text(artist.name)
                .font(.body)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(artist.name)
        .accessibilityAddTraits(.isButton)
    }

    private func albumRow(_ album: AlbumItem) -> some View {
        HStack(spacing: 12) {
            ArtworkImageView(
                source: album.artworkURL,
                width: 48,
                height: 48,
                cornerRadius: 6
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.body)
                    .lineLimit(1)
                Text(album.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(album.title) by \(album.artistName)")
        .accessibilityAddTraits(.isButton)
    }

    private func playlistRow(_ playlist: PlaylistItem) -> some View {
        HStack(spacing: 12) {
            ArtworkImageView(
                source: playlist.artworkURL,
                width: 48,
                height: 48,
                cornerRadius: 6
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(playlist.name)
                    .font(.body)
                    .lineLimit(1)
                Text(playlist.curatorName ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(playlist.name)
        .accessibilityAddTraits(.isButton)
    }
}
