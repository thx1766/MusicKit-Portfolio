import SwiftUI

/// Artist detail screen with top songs list and albums grid.
struct ArtistDetailView: View {
    let artistID: String

    @Environment(\.services) private var services
    @Environment(Router.self) private var router
    @State private var viewModel: ArtistDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                artistContent(viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = ArtistDetailViewModel(
                    artistID: artistID,
                    catalogService: services.catalog
                )
                viewModel = vm
                await vm.load()
            }
        }
    }

    private func artistContent(_ vm: ArtistDetailViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Artist header
                if let artist = vm.artist {
                    artistHeader(artist)
                }

                // Top Songs
                if !vm.topSongs.isEmpty {
                    topSongsSection(vm.topSongs)
                }

                // Albums Grid
                if !vm.albums.isEmpty {
                    albumsGrid(vm.albums)
                }

                if let error = vm.error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding(.bottom, 80)
        }
    }

    // MARK: - Artist Header

    private func artistHeader(_ artist: ArtistItem) -> some View {
        VStack(spacing: 12) {
            ArtworkImageView(
                source: artist.artworkURL,
                width: 160,
                height: 160,
                cornerRadius: 80 // Circular
            )

            Text(artist.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            if !artist.genreNames.isEmpty {
                Text(artist.genreNames.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Top Songs

    private func topSongsSection(_ songs: [SongItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top Songs")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)

            LazyVStack(spacing: 0) {
                ForEach(Array(songs.prefix(10).enumerated()), id: \.element.id) { index, song in
                    TrackRowView(song: song, index: index + 1) {
                        Task {
                            try? await services.player.play(
                                songs: Array(songs.prefix(10)),
                                startingAt: index
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)

                    if index < min(songs.count, 10) - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
    }

    // MARK: - Albums Grid

    private func albumsGrid(_ albums: [AlbumItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Albums")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 150), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(albums) { album in
                    Button {
                        router.navigate(to: .album(id: album.id))
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            ArtworkImageView(
                                source: album.artworkURL,
                                width: 160,
                                height: 160,
                                cornerRadius: 8
                            )

                            Text(album.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            if let date = album.releaseDate {
                                Text(date, format: .dateTime.year())
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(album.title)")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        ArtistDetailView(artistID: "artist-1")
    }
    .environment(\.services, .preview)
    .environment(Router())
}
