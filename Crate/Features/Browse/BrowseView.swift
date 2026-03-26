import SwiftUI

/// The main Browse/Discovery screen — the hero portfolio piece.
/// Implements the "scroll of scrolls" pattern: a vertical scroll of horizontal shelves.
/// Uses LazyVStack to avoid rendering off-screen shelves.
struct BrowseView: View {
    @Environment(\.services) private var services
    @State private var viewModel: BrowseViewModel?

    var body: some View {
        Group {
            if let viewModel {
                browseContent(viewModel)
            } else {
                loadingPlaceholder
            }
        }
        .navigationTitle("Browse")
        .task {
            if viewModel == nil {
                let vm = BrowseViewModel(catalogService: services.catalog)
                viewModel = vm
                await vm.loadCharts()
            }
        }
    }

    // MARK: - Content

    private func browseContent(_ vm: BrowseViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Hero Carousel
                if !vm.heroItems.isEmpty {
                    HeroCarouselView(items: vm.heroItems)
                        .padding(.top, 8)
                } else if vm.isLoading {
                    heroSkeleton
                }

                // Album Shelf
                if let section = vm.albumSection {
                    ShelfView(
                        title: section.title,
                        items: section.items,
                        style: .large
                    ) { album in
                        Route.album(id: album.id)
                    } content: { album in
                        AlbumShelfItemView(album: album)
                    }
                } else if vm.isLoading {
                    shelfSkeleton
                }

                // Playlist Shelf
                if let section = vm.playlistSection {
                    ShelfView(
                        title: section.title,
                        items: section.items,
                        style: .large
                    ) { playlist in
                        Route.playlist(id: playlist.id)
                    } content: { playlist in
                        PlaylistShelfItemView(playlist: playlist)
                    }
                } else if vm.isLoading {
                    shelfSkeleton
                }

                // Song Shelf
                if let section = vm.songSection {
                    ShelfView(
                        title: section.title,
                        items: section.items,
                        style: .compact
                    ) { song in
                        Route.album(id: song.id) // Navigate to album for songs
                    } content: { song in
                        SongShelfItemView(song: song)
                    }
                } else if vm.isLoading {
                    shelfSkeleton
                }

                // Error state
                if let error = vm.error {
                    errorView(error) {
                        Task { await vm.loadCharts() }
                    }
                }
            }
            .padding(.bottom, 80) // Space for mini player
        }
        .refreshable {
            await vm.refresh()
        }
    }

    // MARK: - Skeleton Placeholders

    private var loadingPlaceholder: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroSkeleton
                shelfSkeleton
                shelfSkeleton
            }
        }
    }

    private var heroSkeleton: some View {
        SkeletonView()
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
    }

    private var shelfSkeleton: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView()
                .frame(width: 120, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 8) {
                            SkeletonView()
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            SkeletonView()
                                .frame(width: 120, height: 14)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            SkeletonView()
                                .frame(width: 80, height: 12)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func errorView(_ error: Error, retry: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundStyle(.secondary)

            Text("Something went wrong")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again", action: retry)
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        BrowseView()
    }
    .environment(\.services, .preview)
}
