import Foundation

/// Abstracts music playback for testability.
/// Live implementation wraps `ApplicationMusicPlayer.shared`.
protocol PlayerServiceProtocol: AnyObject, Sendable {

    /// The currently playing/paused track, or nil if queue is empty.
    var nowPlaying: NowPlayingState? { get }

    /// Whether the player is currently playing.
    var isPlaying: Bool { get }

    /// Starts playback of a single song.
    func play(song: SongItem) async throws

    /// Starts playback of a list of songs, optionally starting at a specific song.
    func play(songs: [SongItem], startingAt index: Int) async throws

    /// Toggles play/pause.
    func togglePlayPause() async throws

    /// Skips to the next track.
    func skipToNext() async throws

    /// Skips to the previous track.
    func skipToPrevious() async throws
}
