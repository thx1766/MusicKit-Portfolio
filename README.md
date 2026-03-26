# Crate — MusicKit Portfolio App

A SwiftUI app that lets users browse the Apple Music catalog with a rich, scroll-heavy, content-driven UI. Built to demonstrate proficiency with SwiftUI, MusicKit, scroll performance, lazy loading, and clean architecture.

## Requirements

- Xcode 16+
- iOS 17.0+ deployment target
- Swift 6 language mode
- Apple Developer account with MusicKit entitlement
- Active Apple Music subscription (for playback)

## Architecture

**MVVM** with protocol-oriented services and dependency injection via SwiftUI Environment.

```
Crate/
├── App/              # @main entry, tab view, authorization
├── Navigation/       # Route enum, Router (NavigationStack state)
├── Services/         # Protocol definitions + live MusicKit implementations
│   ├── Protocols/    # CatalogService, SearchService, PlayerService, ImageCache
│   └── Mocks/        # Mock implementations for previews and tests
├── Features/
│   ├── Browse/       # Hero carousel, horizontal shelves, charts
│   ├── Search/       # Debounced search, categorized results
│   ├── Detail/       # Album, Artist, Playlist detail views
│   └── NowPlaying/   # Mini player bar
├── Components/       # Reusable views (ArtworkImage, Skeleton, TrackRow, BlurredHeader)
├── Models/           # Display model structs (AlbumItem, SongItem, etc.)
└── Resources/        # Assets, entitlements, Info.plist
```

### Key Design Decisions

- **Display Models over MusicKit types**: MusicKit types (`Album`, `Song`, etc.) lack public initializers, making them untestable. View models map MusicKit responses to lightweight `Sendable` display model structs. Tests mock at the service protocol level.
- **`@Observable` view models**: iOS 17+ `@Observable` macro for fine-grained observation without `@Published` boilerplate.
- **NSCache image caching**: Size-appropriate artwork requests (display size x scale factor) with `NSCache` and `URLCache` backing. No oversized images for thumbnails.
- **Zero third-party dependencies**: Everything built with Apple frameworks to demonstrate framework-level thinking.

## Features

### Browse (Discovery)
- Hero carousel with editorial/featured content
- Horizontally scrolling shelves (albums, playlists, songs) — the "scroll of scrolls" pattern
- `LazyVStack` + `LazyHStack` for efficient rendering
- Skeleton/shimmer loading placeholders
- Pull-to-refresh

### Search
- 300ms debounced text search via `MusicCatalogSearchRequest`
- Categorized results (Artists, Albums, Songs, Playlists)
- Search suggestions and recent searches
- Keyboard dismiss on scroll

### Detail Views
- Album: blurred artwork header, track list, play/shuffle controls
- Artist: circular artwork, top songs, albums grid
- Playlist: description, track list, curator info

### Now Playing
- Persistent mini player bar with play/pause and skip
- Wraps `ApplicationMusicPlayer.shared`

## Testing

```bash
# Unit tests (with mock services)
xcodebuild test -scheme Crate -destination 'platform=iOS Simulator,name=iPhone 16'
```

- **BrowseViewModelTests**: Charts loading, error handling, hero item derivation
- **SearchViewModelTests**: Debounce behavior, result mapping, suggestion selection
- **AlbumDetailViewModelTests**: Detail loading, metadata formatting
- **ImageCacheTests**: Cache miss/hit, URL generation, nil handling
- **ScrollPerformanceTests**: UI performance test measuring scroll FPS

## Setup

1. Clone the repository
2. Open Xcode → File → New → Project → App
3. Product Name: **Crate**, set your team and bundle ID
4. Set deployment target to **iOS 17.0**, Swift Language Version to **6**
5. Add capability: **MusicKit**
6. Drag the `Crate/` source folder into the project
7. Add `CrateTests/` and `CrateUITests/` as test targets
8. Set `Crate/Resources/Info.plist` and `Crate/Resources/Crate.entitlements` in Build Settings
9. Build and run

## Performance Considerations

- All lists use `LazyVStack`/`LazyHStack`/`LazyVGrid` — off-screen items are not rendered
- Image cache uses `NSCache` with 100MB limit; clears on memory warnings
- Artwork requested at display size x scale factor — never oversized
- View models scope state carefully to minimize redraws
- Skeleton placeholders respect `accessibilityReduceMotion`
- No heavy work in view `body` — data transformation in view models
