import SwiftUI

/// Album detail screen with blurred artwork header, track list, and related albums.
struct AlbumDetailView: View {
    let albumID: String

    @Environment(\.services) private var services
    @State private var viewModel: AlbumDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                albumContent(viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = AlbumDetailViewModel(
                    albumID: albumID,
                    catalogService: services.catalog
                )
                viewModel = vm
                await vm.load()
            }
        }
    }

    private func albumContent(_ vm: AlbumDetailViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Blurred artwork header
                if let album = vm.album {
                    BlurredArtworkHeader(
                        artworkSource: album.artworkURL,
                        title: album.title,
                        subtitle: album.artistName,
                        metadata: vm.metadataString
                    )
                }

                // Play controls
                if let album = vm.album, !vm.tracks.isEmpty {
                    playControls(songs: vm.tracks, album: album)
                        .padding(.horizontal)
                        .padding(.top, 16)
                }

                // Track list
                if !vm.tracks.isEmpty {
                    trackList(vm.tracks)
                        .padding(.top, 8)
                } else if vm.isLoading {
                    trackListSkeleton
                }

                // Related albums shelf
                if !vm.relatedAlbums.isEmpty {
                    relatedAlbumsSection(vm.relatedAlbums)
                        .padding(.top, 24)
                }

                // Error
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

    // MARK: - Play Controls

    private func playControls(songs: [SongItem], album: AlbumItem) -> some View {
        HStack(spacing: 16) {
            Button {
                Task {
                    try? await services.player.play(songs: songs, startingAt: 0)
                }
            } label: {
                Label("Play", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                let shuffled = songs.shuffled()
                Task {
                    try? await services.player.play(songs: shuffled, startingAt: 0)
                }
            } label: {
                Label("Shuffle", systemImage: "shuffle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    // MARK: - Track List

    private func trackList(_ tracks: [SongItem]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                TrackRowView(song: track, index: track.trackNumber ?? (index + 1)) {
                    Task {
                        try? await services.player.play(songs: tracks, startingAt: index)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)

                if index < tracks.count - 1 {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
    }

    private var trackListSkeleton: some View {
        VStack(spacing: 12) {
            ForEach(0..<8, id: \.self) { _ in
                HStack {
                    SkeletonView()
                        .frame(width: 28, height: 14)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    SkeletonView()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonView()
                            .frame(width: 140, height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        SkeletonView()
                            .frame(width: 90, height: 12)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Related Albums

    @Environment(Router.self) private var router

    private func relatedAlbumsSection(_ albums: [AlbumItem]) -> some View {
        ShelfView(
            title: "You Might Also Like",
            items: albums,
            style: .large
        ) { album in
            Route.album(id: album.id)
        } content: { album in
            AlbumShelfItemView(album: album)
        }
    }
}

#Preview {
    NavigationStack {
        AlbumDetailView(albumID: "album-1")
    }
    .environment(\.services, .preview)
    .environment(Router())
}
