import Foundation

/// View model for the mini player and now playing display.
/// Observes the player service for real-time playback state.
@Observable
final class NowPlayingViewModel {
    private let playerService: any PlayerServiceProtocol

    init(playerService: any PlayerServiceProtocol) {
        self.playerService = playerService
    }

    var nowPlaying: NowPlayingState? {
        playerService.nowPlaying
    }

    var isPlaying: Bool {
        playerService.isPlaying
    }

    var hasContent: Bool {
        nowPlaying != nil
    }

    func togglePlayPause() {
        Task {
            try? await playerService.togglePlayPause()
        }
    }

    func skipToNext() {
        Task {
            try? await playerService.skipToNext()
        }
    }
}
