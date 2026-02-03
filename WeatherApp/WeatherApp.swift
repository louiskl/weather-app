import SwiftUI

@main
struct WeatherApp: App {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var streakManager = StreakManager()
    @StateObject private var achievementSystem = AchievementSystem()
    @StateObject private var soundManager = AmbientSoundManager()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentViewPremium()
                .environmentObject(weatherViewModel)
                .environmentObject(streakManager)
                .environmentObject(achievementSystem)
                .environmentObject(soundManager)
                .environmentObject(themeManager)
        }
    }
}
