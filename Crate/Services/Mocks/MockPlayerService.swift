import Foundation

/// Mock player service for previews and unit tests.
@Observable
final class MockPlayerService: PlayerServiceProtocol, @unchecked Sendable {

    var nowPlaying: NowPlayingState?
    var isPlaying: Bool = false

    func play(song: SongItem) async throws {
        nowPlaying = NowPlayingState(
            title: song.title,
            artistName: song.artistName,
            artworkURL: song.artworkURL,
            isPlaying: true,
            playbackTime: 0,
            duration: song.duration
        )
        isPlaying = true
    }

    func play(songs: [SongItem], startingAt index: Int) async throws {
        guard let song = songs[safe: index] ?? songs.first else { return }
        try await play(song: song)
    }

    func togglePlayPause() async throws {
        isPlaying.toggle()
        if let current = nowPlaying {
            nowPlaying = NowPlayingState(
                title: current.title,
                artistName: current.artistName,
                artworkURL: current.artworkURL,
                isPlaying: isPlaying,
                playbackTime: current.playbackTime,
                duration: current.duration
            )
        }
    }

    func skipToNext() async throws {
        // No-op in mock
    }

    func skipToPrevious() async throws {
        // No-op in mock
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
