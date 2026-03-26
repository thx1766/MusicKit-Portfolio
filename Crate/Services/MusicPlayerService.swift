import Foundation
import MusicKit

/// Live player service wrapping ApplicationMusicPlayer.
@Observable
final class MusicPlayerService: PlayerServiceProtocol, @unchecked Sendable {

    private let player = ApplicationMusicPlayer.shared

    var nowPlaying: NowPlayingState? {
        guard let entry = player.queue.currentEntry else { return nil }

        let title: String
        let artistName: String
        let artwork: ArtworkSource?

        switch entry.item {
        case .song(let song):
            title = song.title
            artistName = song.artistName
            artwork = song.artwork?.toArtworkSource()
        default:
            title = entry.title
            artistName = entry.subtitle ?? ""
            artwork = entry.artwork?.toArtworkSource()
        }

        return NowPlayingState(
            title: title,
            artistName: artistName,
            artworkURL: artwork,
            isPlaying: player.state.playbackStatus == .playing,
            playbackTime: player.playbackTime,
            duration: entry.item?.duration
        )
    }

    var isPlaying: Bool {
        player.state.playbackStatus == .playing
    }

    func play(song: SongItem) async throws {
        let musicID = MusicItemID(song.id)
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicID)
        request.properties = [.albums]
        let response = try await request.response()

        guard let musicSong = response.items.first else { return }
        player.queue = ApplicationMusicPlayer.Queue(for: [musicSong])
        try await player.prepareToPlay()
        try await player.play()
    }

    func play(songs: [SongItem], startingAt index: Int) async throws {
        // Fetch all songs from the catalog with album relationships
        let musicIDs = songs.map { MusicItemID($0.id) }
        var allSongs: [Song] = []

        for id in musicIDs {
            var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: id)
            request.properties = [.albums]
            let response = try await request.response()
            if let song = response.items.first {
                allSongs.append(song)
            }
        }

        guard !allSongs.isEmpty else { return }

        player.queue = ApplicationMusicPlayer.Queue(for: allSongs,
                                                     startingAt: allSongs[safe: index])
        try await player.prepareToPlay()
        try await player.play()
    }

    func togglePlayPause() async throws {
        if player.state.playbackStatus == .playing {
            player.pause()
        } else {
            try await player.play()
        }
    }

    func skipToNext() async throws {
        try await player.skipToNextEntry()
    }

    func skipToPrevious() async throws {
        try await player.skipToPreviousEntry()
    }
}

// MARK: - Safe Array Access

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// Extension to get duration from MusicPlayer.Queue.Entry.Item
private extension MusicPlayer.Queue.Entry.Item {
    var duration: TimeInterval? {
        switch self {
        case .song(let song):
            return song.duration
        default:
            return nil
        }
    }
}
