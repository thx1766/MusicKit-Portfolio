import SwiftUI

/// Persistent mini player bar shown at the bottom of the screen.
/// Displays current track info with play/pause and skip controls.
struct MiniPlayerView: View {
    @Environment(\.services) private var services
    @State private var viewModel: NowPlayingViewModel?

    var body: some View {
        Group {
            if let viewModel, viewModel.hasContent {
                miniPlayerContent(viewModel)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = NowPlayingViewModel(playerService: services.player)
            }
        }
    }

    private func miniPlayerContent(_ vm: NowPlayingViewModel) -> some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                // Artwork
                if let state = vm.nowPlaying {
                    ArtworkImageView(
                        source: state.artworkURL,
                        width: 40,
                        height: 40,
                        cornerRadius: 6
                    )

                    // Track info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(state.title)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .lineLimit(1)

                        Text(state.artistName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Controls
                HStack(spacing: 16) {
                    Button(action: vm.togglePlayPause) {
                        Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel(vm.isPlaying ? "Pause" : "Play")

                    Button(action: vm.skipToNext) {
                        Image(systemName: "forward.fill")
                            .font(.body)
                    }
                    .accessibilityLabel("Next track")
                }
                .foregroundStyle(.primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Now Playing")
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView()
    }
    .environment(\.services, .preview)
}
