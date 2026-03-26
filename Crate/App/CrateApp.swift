import SwiftUI
import MusicKit

@main
struct CrateApp: App {
    @State private var authorizationStatus = MusicAuthorization.currentStatus

    var body: some Scene {
        WindowGroup {
            Group {
                switch authorizationStatus {
                case .authorized:
                    ContentView()
                default:
                    AuthorizationView(status: $authorizationStatus)
                }
            }
            .environment(\.services, .live)
        }
    }
}

// MARK: - Authorization View

/// Shown when the user hasn't granted MusicKit access.
/// Explains why access is needed and provides a button to request it.
struct AuthorizationView: View {
    @Binding var status: MusicAuthorization.Status

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "music.note.house.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text("Welcome to Crate")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Crate needs access to Apple Music to browse the catalog and play music.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            switch status {
            case .notDetermined:
                Button("Continue") {
                    Task {
                        status = await MusicAuthorization.request()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            case .denied:
                VStack(spacing: 12) {
                    Text("Access Denied")
                        .font(.headline)
                        .foregroundStyle(.red)

                    Text("Please enable Apple Music access in Settings.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                }

            case .restricted:
                Text("Apple Music access is restricted on this device.")
                    .font(.body)
                    .foregroundStyle(.secondary)

            default:
                EmptyView()
            }

            Spacer()
        }
        .accessibilityElement(children: .contain)
    }
}
