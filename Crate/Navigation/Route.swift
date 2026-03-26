import Foundation

/// Type-safe navigation destinations used with NavigationStack.
enum Route: Hashable {
    case album(id: String)
    case artist(id: String)
    case playlist(id: String)
}
