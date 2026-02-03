import SwiftUI

/// Premium ContentView mit allen neuen Features
struct ContentViewPremium: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var achievementSystem: AchievementSystem
    @EnvironmentObject var soundManager: AmbientSoundManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showSearch = false
    @State private var showSettings = false
    @State private var showShareCard = false
    @State private var showSoundPicker = false
    @State private var showThemePicker = false
    @State private var showStreakDetail = false
    @State private var use3DBackground = true
    
    var body: some View {
        ZStack {
            // Hintergrund (3D oder Gradient)
            backgroundView
                .ignoresSafeArea()
            
            // Hauptinhalt
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                if viewModel.isLoading {
                    Spacer()
                    LoadingView()
                    Spacer()
                } else if viewModel.weatherResponse != nil {
                    // Bento Grid Dashboard
                    BentoGridView()
                        .environmentObject(viewModel)
                        .environmentObject(streakManager)
                        .environmentObject(achievementSystem)
                        .environmentObject(soundManager)
                } else {
                    emptyStateView
                }
            }
            
            // Search Overlay
            if showSearch {
                SearchOverlay(isPresented: $showSearch)
                    .environmentObject(viewModel)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSearch)
        .sheet(isPresented: $showSettings) {
            SettingsView(use3DBackground: $use3DBackground)
                .environmentObject(soundManager)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showShareCard) {
            ShareCardGeneratorView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerView()
                .environmentObject(soundManager)
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePickerView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showStreakDetail) {
            StreakDetailView()
                .environmentObject(streakManager)
        }
        .alert("Fehler", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Ein Fehler ist aufgetreten")
        }
        .task {
            await viewModel.loadInitialWeather()
            streakManager.checkIn()
            
            // Achievements prüfen
            if let weather = viewModel.weatherResponse {
                achievementSystem.checkWeatherAchievements(weather: weather)
                achievementSystem.checkLocationAchievement(country: weather.location.country)
                
                // Sound abspielen
                soundManager.playRecommended(for: viewModel.currentCondition)
            }
        }
        .onChange(of: viewModel.weatherResponse) { _, newValue in
            if let weather = newValue {
                achievementSystem.checkWeatherAchievements(weather: weather)
                
                // Haptic Feedback bei Wetter-Wechsel
                HapticEngine.shared.weatherChanged(to: viewModel.currentCondition)
            }
        }
        // Achievement Unlock Animation
        .overlay {
            if achievementSystem.showUnlockAnimation, let achievement = achievementSystem.recentlyUnlocked {
                AchievementUnlockView(
                    achievement: achievement,
                    isPresented: $achievementSystem.showUnlockAnimation
                )
            }
        }
    }
    
    // MARK: - Background View
    
    @ViewBuilder
    private var backgroundView: some View {
        if use3DBackground {
            WeatherScene3DContainer(
                condition: viewModel.currentCondition,
                isDay: viewModel.weatherResponse?.current.isDay == 1
            )
        } else {
            WeatherBackground(condition: viewModel.currentCondition)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            // Standort-Button
            Button {
                HapticEngine.shared.buttonTap()
                Task {
                    await viewModel.fetchWeatherForCurrentLocation()
                }
            } label: {
                Image(systemName: "location.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.configuration.textColor)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Stadtname (tappable für Streak)
            Button {
                showStreakDetail = true
            } label: {
                VStack(spacing: 2) {
                    HStack(spacing: 6) {
                        Text(viewModel.cityName)
                            .font(.headline)
                        
                        // Streak Badge
                        if streakManager.currentStreak > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                Text("\(streakManager.currentStreak)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    
                    if !viewModel.countryName.isEmpty {
                        Text(viewModel.countryName)
                            .font(.caption)
                            .foregroundColor(themeManager.configuration.secondaryTextColor)
                    }
                }
                .foregroundColor(themeManager.configuration.textColor)
            }
            
            Spacer()
            
            // Menü-Buttons
            HStack(spacing: 8) {
                // Suche
                Button {
                    HapticEngine.shared.buttonTap()
                    withAnimation {
                        showSearch.toggle()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                }
                
                // Share
                Button {
                    HapticEngine.shared.buttonTap()
                    showShareCard = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                }
                
                // Settings
                Button {
                    HapticEngine.shared.buttonTap()
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                }
            }
            .foregroundColor(themeManager.configuration.textColor)
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "cloud.sun")
                .font(.system(size: 60))
                .foregroundColor(themeManager.configuration.textColor.opacity(0.6))
            
            Text("Keine Wetterdaten")
                .font(.title2)
                .foregroundColor(themeManager.configuration.textColor)
            
            Text("Suche nach einer Stadt oder nutze deinen Standort")
                .font(.subheadline)
                .foregroundColor(themeManager.configuration.secondaryTextColor)
                .multilineTextAlignment(.center)
            
            Button {
                withAnimation {
                    showSearch = true
                }
            } label: {
                Label("Stadt suchen", systemImage: "magnifyingglass")
                    .font(.headline)
                    .foregroundColor(themeManager.configuration.textColor)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var soundManager: AmbientSoundManager
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var use3DBackground: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var hapticsEnabled = HapticEngine.shared.isEnabled
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: themeManager.configuration.primaryGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    // Darstellung
                    Section {
                        Toggle("3D-Hintergrund", isOn: $use3DBackground)
                        
                        NavigationLink {
                            ThemePickerView()
                                .environmentObject(themeManager)
                        } label: {
                            HStack {
                                Text("Theme")
                                Spacer()
                                Text(themeManager.currentTheme.displayName)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("Darstellung")
                    }
                    
                    // Sound
                    Section {
                        Toggle("Ambient Sounds", isOn: $soundManager.autoPlayEnabled)
                        
                        if soundManager.autoPlayEnabled {
                            NavigationLink {
                                SoundPickerView()
                                    .environmentObject(soundManager)
                            } label: {
                                HStack {
                                    Text("Sound auswählen")
                                    Spacer()
                                    Text(soundManager.currentSound?.displayName ?? "Keiner")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Lautstärke")
                                Slider(value: Binding(
                                    get: { Double(soundManager.volume) },
                                    set: { soundManager.setVolume(Float($0)) }
                                ))
                            }
                        }
                    } header: {
                        Text("Sound")
                    }
                    
                    // Haptics
                    Section {
                        Toggle("Haptisches Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                HapticEngine.shared.setEnabled(newValue)
                            }
                    } header: {
                        Text("Haptik")
                    }
                    
                    // Info
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("2.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        Link(destination: URL(string: "https://www.weatherapi.com")!) {
                            HStack {
                                Text("Wetterdaten von WeatherAPI.com")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                            }
                        }
                    } header: {
                        Text("Info")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }
}

// Extension für HapticEngine
extension HapticEngine {
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "haptics_enabled") as? Bool ?? true
    }
}

// MARK: - Preview

#Preview {
    ContentViewPremium()
        .environmentObject(WeatherViewModel())
        .environmentObject(StreakManager())
        .environmentObject(AchievementSystem())
        .environmentObject(AmbientSoundManager())
        .environmentObject(ThemeManager())
}
