import SwiftUI

/// Root tab view housing Browse and Search tabs.
/// The mini player bar persists at the bottom across all tabs.
struct ContentView: View {
    @Environment(\.services) private var services
    @State private var selectedTab: Tab = .browse
    @State private var browseRouter = Router()
    @State private var searchRouter = Router()

    var body: some View {
        TabView(selection: $selectedTab) {
            browseTab
                .tag(Tab.browse)
                .tabItem {
                    Label("Browse", systemImage: "square.grid.2x2.fill")
                }

            searchTab
                .tag(Tab.search)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .safeAreaInset(edge: .bottom) {
            MiniPlayerView()
                .transition(.move(edge: .bottom))
        }
    }

    // MARK: - Tabs

    private var browseTab: some View {
        NavigationStack(path: $browseRouter.path) {
            BrowseView()
                .navigationDestinations()
        }
        .environment(browseRouter)
    }

    private var searchTab: some View {
        NavigationStack(path: $searchRouter.path) {
            SearchView()
                .navigationDestinations()
        }
        .environment(searchRouter)
    }
}

// MARK: - Tab Enum

private enum Tab {
    case browse
    case search
}

// MARK: - Navigation Destinations

extension View {
    func navigationDestinations() -> some View {
        self
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .album(let id):
                    AlbumDetailView(albumID: id)
                case .artist(let id):
                    ArtistDetailView(artistID: id)
                case .playlist(let id):
                    PlaylistDetailView(playlistID: id)
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(\.services, .preview)
}
