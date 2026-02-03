import SwiftUI

// MARK: - App Theme

enum AppTheme: String, CaseIterable, Codable {
    case standard = "Standard"
    case neonCity = "Neon City"
    case cottageCore = "Cottage Core"
    case minimal = "Minimal"
    case retroPixel = "Retro Pixel"
    
    var displayName: String { rawValue }
    
    var description: String {
        switch self {
        case .standard: return "Modernes, sauberes Design"
        case .neonCity: return "Cyberpunk-Ästhetik mit Neon-Farben"
        case .cottageCore: return "Gemütlich und naturverbunden"
        case .minimal: return "Reduziert auf das Wesentliche"
        case .retroPixel: return "8-Bit Nostalgie"
        }
    }
    
    var previewColors: [Color] {
        switch self {
        case .standard: return [.blue, .purple, .pink]
        case .neonCity: return [.black, .cyan, .pink]
        case .cottageCore: return [.brown, .green, .orange]
        case .minimal: return [.white, .gray, .black]
        case .retroPixel: return [.green, .blue, .purple]
        }
    }
    
    var isUnlocked: Bool {
        switch self {
        case .standard: return true
        default:
            let unlockedThemes = UserDefaults.standard.stringArray(forKey: "unlocked_themes") ?? []
            return unlockedThemes.contains(rawValue)
        }
    }
    
    var unlockRequirement: String {
        switch self {
        case .standard: return "Standard"
        case .neonCity: return "7 Tage Streak"
        case .cottageCore: return "5 Schneetage erlebt"
        case .minimal: return "30 Tage Streak"
        case .retroPixel: return "100 Punkte im Vorhersage-Spiel"
        }
    }
}

// MARK: - Theme Configuration

struct ThemeConfiguration {
    let primaryGradient: [Color]
    let accentColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let cardBackground: Color
    let cardOpacity: Double
    let cornerRadius: CGFloat
    let fontDesign: Font.Design
    let useBlur: Bool
    
    static func configuration(for theme: AppTheme) -> ThemeConfiguration {
        switch theme {
        case .standard:
            return ThemeConfiguration(
                primaryGradient: [.blue, .purple],
                accentColor: .cyan,
                textColor: .white,
                secondaryTextColor: .white.opacity(0.7),
                cardBackground: .white,
                cardOpacity: 0.1,
                cornerRadius: 20,
                fontDesign: .rounded,
                useBlur: true
            )
            
        case .neonCity:
            return ThemeConfiguration(
                primaryGradient: [.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                accentColor: .cyan,
                textColor: .white,
                secondaryTextColor: .cyan.opacity(0.7),
                cardBackground: .black,
                cardOpacity: 0.8,
                cornerRadius: 10,
                fontDesign: .monospaced,
                useBlur: false
            )
            
        case .cottageCore:
            return ThemeConfiguration(
                primaryGradient: [Color(red: 0.9, green: 0.85, blue: 0.75), Color(red: 0.7, green: 0.8, blue: 0.6)],
                accentColor: .brown,
                textColor: Color(red: 0.3, green: 0.25, blue: 0.2),
                secondaryTextColor: Color(red: 0.5, green: 0.45, blue: 0.4),
                cardBackground: .white,
                cardOpacity: 0.6,
                cornerRadius: 15,
                fontDesign: .serif,
                useBlur: true
            )
            
        case .minimal:
            return ThemeConfiguration(
                primaryGradient: [.white, Color(white: 0.95)],
                accentColor: .black,
                textColor: .black,
                secondaryTextColor: .gray,
                cardBackground: .black,
                cardOpacity: 0.05,
                cornerRadius: 12,
                fontDesign: .default,
                useBlur: false
            )
            
        case .retroPixel:
            return ThemeConfiguration(
                primaryGradient: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.15, green: 0.1, blue: 0.25)],
                accentColor: .green,
                textColor: .green,
                secondaryTextColor: .green.opacity(0.6),
                cardBackground: .green,
                cardOpacity: 0.1,
                cornerRadius: 0,
                fontDesign: .monospaced,
                useBlur: false
            )
        }
    }
}

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "current_theme")
            configuration = ThemeConfiguration.configuration(for: currentTheme)
        }
    }
    
    @Published var configuration: ThemeConfiguration
    @Published var unlockedThemes: Set<String> = []
    
    // MARK: - Initialization
    
    init() {
        // Load saved theme
        if let savedTheme = UserDefaults.standard.string(forKey: "current_theme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
            self.configuration = ThemeConfiguration.configuration(for: theme)
        } else {
            self.currentTheme = .standard
            self.configuration = ThemeConfiguration.configuration(for: .standard)
        }
        
        // Load unlocked themes
        if let unlocked = UserDefaults.standard.stringArray(forKey: "unlocked_themes") {
            unlockedThemes = Set(unlocked)
        }
        unlockedThemes.insert(AppTheme.standard.rawValue)
    }
    
    // MARK: - Public Methods
    
    func setTheme(_ theme: AppTheme) {
        guard theme.isUnlocked || unlockedThemes.contains(theme.rawValue) else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
    }
    
    func unlockTheme(_ theme: AppTheme) {
        unlockedThemes.insert(theme.rawValue)
        UserDefaults.standard.set(Array(unlockedThemes), forKey: "unlocked_themes")
    }
    
    func checkUnlockConditions(streak: Int, achievements: [Achievement], predictionPoints: Int) {
        // Neon City: 7 Tage Streak
        if streak >= 7 {
            unlockTheme(.neonCity)
        }
        
        // Cottage Core: 5 Schneetage
        if achievements.first(where: { $0.id == "snow_queen" })?.progress ?? 0 >= 5 {
            unlockTheme(.cottageCore)
        }
        
        // Minimal: 30 Tage Streak
        if streak >= 30 {
            unlockTheme(.minimal)
        }
        
        // Retro Pixel: 100 Vorhersage-Punkte
        if predictionPoints >= 100 {
            unlockTheme(.retroPixel)
        }
    }
}

// MARK: - Theme Picker View

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: themeManager.configuration.primaryGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Current Theme Preview
                        CurrentThemePreview()
                            .environmentObject(themeManager)
                        
                        // Theme Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                ThemeCard(
                                    theme: theme,
                                    isSelected: themeManager.currentTheme == theme,
                                    isUnlocked: theme.isUnlocked || themeManager.unlockedThemes.contains(theme.rawValue)
                                ) {
                                    if theme.isUnlocked || themeManager.unlockedThemes.contains(theme.rawValue) {
                                        themeManager.setTheme(theme)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .foregroundColor(themeManager.configuration.textColor)
                }
            }
        }
    }
}

struct CurrentThemePreview: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Aktuelles Theme")
                .font(.caption)
                .foregroundColor(themeManager.configuration.secondaryTextColor)
            
            Text(themeManager.currentTheme.displayName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(themeManager.configuration.textColor)
            
            Text(themeManager.currentTheme.description)
                .font(.subheadline)
                .foregroundColor(themeManager.configuration.secondaryTextColor)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            themeManager.configuration.useBlur ?
            AnyView(Color.white.opacity(0.1).background(.ultraThinMaterial)) :
            AnyView(themeManager.configuration.cardBackground.opacity(themeManager.configuration.cardOpacity))
        )
        .cornerRadius(themeManager.configuration.cornerRadius)
        .padding(.horizontal)
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let isUnlocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: theme.previewColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                    
                    if !isUnlocked {
                        Color.black.opacity(0.5)
                            .cornerRadius(10)
                        
                        Image(systemName: "lock.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 3)
                    }
                }
                
                // Info
                VStack(spacing: 4) {
                    Text(theme.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    if !isUnlocked {
                        Text(theme.unlockRequirement)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(isSelected ? 0.2 : 0.1))
            .cornerRadius(15)
        }
        .disabled(!isUnlocked)
    }
}
