import SwiftUI

/// Suchleiste für die Stadteingabe
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Stadt eingeben..."
    var onSearch: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Suchfeld
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        if !text.trimmed.isEmpty {
                            onSearch()
                        }
                    }
                
                // Clear-Button
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            
            // Such-Button
            Button {
                isFocused = false
                onSearch()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .disabled(text.trimmed.isEmpty)
            .opacity(text.trimmed.isEmpty ? 0.5 : 1)
        }
    }
}

// MARK: - Inline Search Bar (kompaktere Version)

struct InlineSearchBar: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Stadt suchen...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    performSearch()
                }
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            if !viewModel.searchText.trimmed.isEmpty {
                Button {
                    performSearch()
                } label: {
                    Text("Suchen")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
    
    private func performSearch() {
        isFocused = false
        Task {
            await viewModel.performSearch()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        WeatherBackground(condition: .sunny)
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            SearchBar(text: .constant("Berlin")) {
                print("Search")
            }
            
            SearchBar(text: .constant("")) {
                print("Search")
            }
            
            InlineSearchBar()
                .environmentObject(WeatherViewModel())
        }
        .padding()
    }
}
