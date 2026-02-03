import Foundation
import SwiftUI

// MARK: - Achievement Model

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    var progress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    var progressPercentage: Double {
        min(Double(progress) / Double(requirement), 1.0)
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case weather = "Wetter-Erlebnisse"
    case streak = "Streaks"
    case explorer = "Entdecker"
    case seasonal = "Saisonal"
    
    var color: Color {
        switch self {
        case .weather: return .blue
        case .streak: return .orange
        case .explorer: return .green
        case .seasonal: return .purple
        }
    }
}

// MARK: - Achievement System

@MainActor
final class AchievementSystem: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var achievements: [Achievement] = []
    @Published var recentlyUnlocked: Achievement?
    @Published var showUnlockAnimation: Bool = false
    
    // MARK: - Computed Properties
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    // MARK: - Initialization
    
    init() {
        loadAchievements()
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    /// Aktualisiert den Fortschritt eines Achievements
    func updateProgress(for achievementId: String, progress: Int) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }) else { return }
        
        achievements[index].progress = progress
        
        if progress >= achievements[index].requirement && !achievements[index].isUnlocked {
            unlockAchievement(at: index)
        }
        
        saveAchievements()
    }
    
    /// Erhöht den Fortschritt um einen bestimmten Wert
    func incrementProgress(for achievementId: String, by amount: Int = 1) {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }) else { return }
        
        let newProgress = achievements[index].progress + amount
        updateProgress(for: achievementId, progress: newProgress)
    }
    
    /// Prüft Wetter-basierte Achievements
    func checkWeatherAchievements(weather: WeatherResponse?) {
        guard let weather = weather else { return }
        
        let condition = WeatherCondition(code: weather.current.condition.code)
        
        // Wetter-Typ Achievements
        switch condition {
        case .thunderstorm:
            incrementProgress(for: "storm_chaser")
        case .sunny:
            incrementProgress(for: "sun_worshipper")
        case .snow:
            incrementProgress(for: "snow_queen")
        case .rain, .heavyRain:
            incrementProgress(for: "rain_dancer")
        default:
            break
        }
        
        // Temperatur-basierte Achievements
        if weather.current.tempC >= 30 {
            incrementProgress(for: "heatwave_survivor")
        }
        if weather.current.tempC <= 0 {
            incrementProgress(for: "frost_fighter")
        }
    }
    
    /// Prüft Standort-basierte Achievements
    func checkLocationAchievement(country: String) {
        // Speichere besuchte Länder
        var visitedCountries = UserDefaults.standard.stringArray(forKey: "visited_countries") ?? []
        
        if !visitedCountries.contains(country) {
            visitedCountries.append(country)
            UserDefaults.standard.set(visitedCountries, forKey: "visited_countries")
            
            updateProgress(for: "globetrotter", progress: visitedCountries.count)
        }
    }
    
    // MARK: - Private Methods
    
    private func unlockAchievement(at index: Int) {
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        
        recentlyUnlocked = achievements[index]
        showUnlockAnimation = true
        
        // Haptic Feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        saveAchievements()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .streakUpdated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let streak = notification.userInfo?["streak"] as? Int {
                self?.checkStreakAchievements(streak: streak)
            }
        }
    }
    
    private func checkStreakAchievements(streak: Int) {
        if streak >= 7 {
            updateProgress(for: "week_warrior", progress: streak)
        }
        if streak >= 30 {
            updateProgress(for: "monthly_master", progress: streak)
        }
        if streak >= 100 {
            updateProgress(for: "century_club", progress: streak)
        }
        if streak >= 365 {
            updateProgress(for: "year_legend", progress: streak)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = saved
        } else {
            // Erstelle Standard-Achievements
            achievements = Self.defaultAchievements
            saveAchievements()
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: "achievements")
        }
    }
    
    // MARK: - Default Achievements
    
    static let defaultAchievements: [Achievement] = [
        // Wetter-Erlebnisse
        Achievement(
            id: "storm_chaser",
            title: "Sturmjäger",
            description: "Erlebe 10 Gewitter",
            icon: "cloud.bolt.fill",
            category: .weather,
            requirement: 10,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "sun_worshipper",
            title: "Sonnenanbeter",
            description: "30 Tage mit Sonnenschein",
            icon: "sun.max.fill",
            category: .weather,
            requirement: 30,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "snow_queen",
            title: "Schneekönigin",
            description: "Erlebe 5 Schneetage",
            icon: "snowflake",
            category: .weather,
            requirement: 5,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "rain_dancer",
            title: "Regentänzer",
            description: "20 Regentage erlebt",
            icon: "cloud.rain.fill",
            category: .weather,
            requirement: 20,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "heatwave_survivor",
            title: "Hitzewellen-Überlebender",
            description: "10 Tage über 30°C erlebt",
            icon: "thermometer.sun.fill",
            category: .weather,
            requirement: 10,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "frost_fighter",
            title: "Frostkämpfer",
            description: "10 Tage unter 0°C erlebt",
            icon: "thermometer.snowflake",
            category: .weather,
            requirement: 10,
            progress: 0,
            isUnlocked: false
        ),
        
        // Streak Achievements
        Achievement(
            id: "week_warrior",
            title: "Wochen-Krieger",
            description: "7 Tage Streak erreichen",
            icon: "flame.fill",
            category: .streak,
            requirement: 7,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "monthly_master",
            title: "Monats-Meister",
            description: "30 Tage Streak erreichen",
            icon: "flame.fill",
            category: .streak,
            requirement: 30,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "century_club",
            title: "100er Club",
            description: "100 Tage Streak erreichen",
            icon: "star.fill",
            category: .streak,
            requirement: 100,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "year_legend",
            title: "Jahres-Legende",
            description: "365 Tage Streak erreichen",
            icon: "crown.fill",
            category: .streak,
            requirement: 365,
            progress: 0,
            isUnlocked: false
        ),
        
        // Entdecker
        Achievement(
            id: "globetrotter",
            title: "Globetrotter",
            description: "Wetter in 10 Ländern gecheckt",
            icon: "globe.europe.africa.fill",
            category: .explorer,
            requirement: 10,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "early_bird",
            title: "Frühaufsteher",
            description: "7x vor 6 Uhr Wetter gecheckt",
            icon: "sunrise.fill",
            category: .explorer,
            requirement: 7,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "night_owl",
            title: "Nachteule",
            description: "7x nach Mitternacht gecheckt",
            icon: "moon.stars.fill",
            category: .explorer,
            requirement: 7,
            progress: 0,
            isUnlocked: false
        ),
        
        // Saisonal
        Achievement(
            id: "spring_awakening",
            title: "Frühlingserwachen",
            description: "Ersten Frühlingstag erlebt",
            icon: "leaf.fill",
            category: .seasonal,
            requirement: 1,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "summer_vibes",
            title: "Summer Vibes",
            description: "Ersten Sommertag über 25°C",
            icon: "sun.horizon.fill",
            category: .seasonal,
            requirement: 1,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "autumn_gold",
            title: "Herbstgold",
            description: "Ersten Herbststurm erlebt",
            icon: "wind",
            category: .seasonal,
            requirement: 1,
            progress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "winter_magic",
            title: "Winterzauber",
            description: "Ersten Schnee der Saison",
            icon: "snowflake",
            category: .seasonal,
            requirement: 1,
            progress: 0,
            isUnlocked: false
        ),
    ]
}

// MARK: - Achievements View

struct AchievementsView: View {
    @EnvironmentObject var achievementSystem: AchievementSystem
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: AchievementCategory?
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementSystem.achievements.filter { $0.category == category }
        }
        return achievementSystem.achievements
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.indigo, .purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Stats Header
                        HStack(spacing: 30) {
                            VStack {
                                Text("\(achievementSystem.unlockedCount)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Freigeschaltet")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            VStack {
                                Text("\(achievementSystem.totalCount)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Gesamt")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding()
                        
                        // Kategorie Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CategoryFilterButton(
                                    title: "Alle",
                                    isSelected: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }
                                
                                ForEach(AchievementCategory.allCases, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category.rawValue,
                                        color: category.color,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Achievements Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    var color: Color = .white
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color.opacity(0.5) : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.category.color : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            if !achievement.isUnlocked {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(achievement.category.color)
                            .frame(width: geometry.size.width * achievement.progressPercentage)
                    }
                }
                .frame(height: 6)
                
                Text("\(achievement.progress)/\(achievement.requirement)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Achievement Unlock Animation

struct AchievementUnlockView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Achievement Freigeschaltet!")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                ZStack {
                    Circle()
                        .fill(achievement.category.color)
                        .frame(width: 120, height: 120)
                        .shadow(color: achievement.category.color, radius: 30)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                
                Text(achievement.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Text("Super!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(achievement.category.color)
                        .cornerRadius(25)
                }
                .padding(.top, 20)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
