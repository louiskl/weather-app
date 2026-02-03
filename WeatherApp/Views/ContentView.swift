import SwiftUI

/// Hauptansicht der Wetter-App
struct ContentView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var showSearch = false
    
    var body: some View {
        ZStack {
            // Dynamischer Hintergrund
            WeatherBackground(condition: viewModel.currentCondition)
                .ignoresSafeArea()
            
            // Hauptinhalt
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header mit Suche
                    headerView
                    
                    if viewModel.isLoading {
                        // Ladeansicht
                        LoadingView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else if viewModel.weatherResponse != nil {
                        // Wetterdaten
                        weatherContent
                    } else {
                        // Keine Daten
                        emptyStateView
                    }
                }
                .padding()
            }
            .refreshable {
                await viewModel.refreshWeather()
            }
            
            // Suchansicht als Overlay
            if showSearch {
                SearchOverlay(isPresented: $showSearch)
                    .environmentObject(viewModel)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSearch)
        .alert("Fehler", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Ein Fehler ist aufgetreten")
        }
        .task {
            await viewModel.loadInitialWeather()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // Standort-Button
            Button {
                Task {
                    await viewModel.fetchWeatherForCurrentLocation()
                }
            } label: {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Stadtname
            VStack {
                Text(viewModel.cityName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if !viewModel.countryName.isEmpty {
                    Text(viewModel.countryName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Such-Button
            Button {
                withAnimation {
                    showSearch.toggle()
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Weather Content
    
    private var weatherContent: some View {
        VStack(spacing: 25) {
            // Aktuelles Wetter
            CurrentWeatherView()
                .environmentObject(viewModel)
            
            // Stündliche Vorhersage
            if !viewModel.hourlyForecast.isEmpty {
                HourlyForecastView()
                    .environmentObject(viewModel)
            }
            
            // Details
            WeatherDetailsView()
                .environmentObject(viewModel)
            
            // 5-Tage-Vorhersage
            if !viewModel.forecast.isEmpty {
                ForecastView()
                    .environmentObject(viewModel)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Keine Wetterdaten")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("Suche nach einer Stadt oder nutze deinen Standort")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button {
                withAnimation {
                    showSearch = true
                }
            } label: {
                Label("Stadt suchen", systemImage: "magnifyingglass")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
            }
        }
        .padding(.top, 80)
    }
}

// MARK: - Search Overlay

struct SearchOverlay: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Binding var isPresented: Bool
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // Hintergrund abdunkeln
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissSearch()
                }
            
            VStack(spacing: 0) {
                // Suchfeld
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Stadt eingeben...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .focused($isSearchFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Suchen") {
                        performSearch()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.searchText.trimmed.isEmpty)
                }
                .padding()
                .background(.ultraThickMaterial)
                .cornerRadius(15)
                .padding()
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .onAppear {
            isSearchFocused = true
        }
    }
    
    private func performSearch() {
        Task {
            await viewModel.performSearch()
            dismissSearch()
        }
    }
    
    private func dismissSearch() {
        isSearchFocused = false
        withAnimation {
            isPresented = false
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(WeatherViewModel())
}
