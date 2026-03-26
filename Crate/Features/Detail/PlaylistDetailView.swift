import SwiftUI

/// Playlist detail screen with blurred artwork header, description, and track list.
struct PlaylistDetailView: View {
    let playlistID: String

    @Environment(\.services) private var services
    @State private var viewModel: PlaylistDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                playlistContent(viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                let vm = PlaylistDetailViewModel(
                    playlistID: playlistID,
                    catalogService: services.catalog
                )
                viewModel = vm
                await vm.load()
            }
        }
    }

    private func playlistContent(_ vm: PlaylistDetailViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Header
                if let playlist = vm.playlist {
                    BlurredArtworkHeader(
                        artworkSource: playlist.artworkURL,
                        title: playlist.name,
                        subtitle: playlist.curatorName ?? "",
                        metadata: vm.metadataString
                    )

                    // Description
                    if let description = playlist.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                            .lineLimit(3)
                    }
                }

                // Play controls
                if !vm.tracks.isEmpty {
                    playControls(vm.tracks)
                        .padding(.horizontal)
                        .padding(.top, 12)
                }

                // Track list
                if !vm.tracks.isEmpty {
                    trackList(vm.tracks)
                        .padding(.top, 8)
                } else if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
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

    // MARK: - Play Controls

    private func playControls(_ songs: [SongItem]) -> some View {
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
                TrackRowView(song: track, index: index + 1) {
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
}

#Preview {
    NavigationStack {
        PlaylistDetailView(playlistID: "playlist-1")
    }
    .environment(\.services, .preview)
    .environment(Router())
}
