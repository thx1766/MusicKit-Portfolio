import SwiftUI

/// Search screen with debounced text input and categorized results.
/// Dismisses keyboard on scroll for a native feel.
struct SearchView: View {
    @Environment(\.services) private var services
    @State private var viewModel: SearchViewModel?

    var body: some View {
        Group {
            if let viewModel {
                searchContent(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Search")
        .task {
            if viewModel == nil {
                viewModel = SearchViewModel(searchService: services.search)
            }
        }
    }

    @ViewBuilder
    private func searchContent(_ vm: SearchViewModel) -> some View {
        @Bindable var vm = vm
        List {
            if vm.searchText.isEmpty {
                recentSearchesSection(vm)
            } else if vm.showSuggestions && !vm.suggestions.isEmpty {
                suggestionsSection(vm)
            } else if vm.isSearching {
                searchingIndicator
            } else if !vm.results.isEmpty {
                SearchResultsView(results: vm.results)
            } else if !vm.searchText.isEmpty {
                noResultsView(vm.searchText)
            }
        }
        .listStyle(.plain)
        .searchable(text: $vm.searchText, prompt: "Artists, Songs, Albums")
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Recent Searches

    private func recentSearchesSection(_ vm: SearchViewModel) -> some View {
        Section {
            ForEach(vm.recentSearches, id: \.self) { term in
                Button {
                    vm.selectSuggestion(term)
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(term)
                            .foregroundStyle(.primary)
                    }
                }
            }
        } header: {
            if !vm.recentSearches.isEmpty {
                HStack {
                    Text("Recent")
                    Spacer()
                    Button("Clear") {
                        vm.clearRecentSearches()
                    }
                    .font(.caption)
                }
            }
        }
    }

    // MARK: - Suggestions

    private func suggestionsSection(_ vm: SearchViewModel) -> some View {
        Section("Suggestions") {
            ForEach(vm.suggestions, id: \.self) { suggestion in
                Button {
                    vm.selectSuggestion(suggestion)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        Text(suggestion)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    // MARK: - States

    private var searchingIndicator: some View {
        HStack {
            Spacer()
            ProgressView("Searching...")
            Spacer()
        }
        .listRowSeparator(.hidden)
        .padding()
    }

    private func noResultsView(_ term: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title)
                .foregroundStyle(.secondary)
            Text("No results for \"\(term)\"")
                .font(.headline)
            Text("Check the spelling or try a new search.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environment(\.services, .preview)
    .environment(Router())
}
