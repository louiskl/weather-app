import Foundation
import SwiftUI

/// Verwaltet das tägliche Streak-System
@MainActor
final class StreakManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Aktueller Streak in Tagen
    @Published var currentStreak: Int = 0
    
    /// Längster jemals erreichter Streak
    @Published var longestStreak: Int = 0
    
    /// Anzahl verfügbarer Streak-Freezes
    @Published var freezesAvailable: Int = 1
    
    /// Datum des letzten Check-ins
    @Published var lastCheckIn: Date?
    
    /// Wurde heute bereits eingecheckt?
    @Published var checkedInToday: Bool = false
    
    /// Zeigt Streak-Verlust Warnung
    @Published var showStreakWarning: Bool = false
    
    // MARK: - Constants
    
    private enum Keys {
        static let currentStreak = "streak_current"
        static let longestStreak = "streak_longest"
        static let lastCheckIn = "streak_lastCheckIn"
        static let freezesAvailable = "streak_freezes"
        static let freezeUsedThisWeek = "streak_freezeUsedThisWeek"
    }
    
    /// Streak-Meilensteine für Belohnungen
    static let milestones = [7, 14, 30, 60, 100, 200, 365]
    
    // MARK: - Initialization
    
    init() {
        loadData()
        checkStreakStatus()
    }
    
    // MARK: - Public Methods
    
    /// Führt den täglichen Check-in durch
    func checkIn() {
        let today = Calendar.current.startOfDay(for: Date())
        
        guard !checkedInToday else { return }
        
        if let lastDate = lastCheckIn {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Perfekt - Streak fortsetzen
                currentStreak += 1
            } else if daysDifference == 2 && freezesAvailable > 0 {
                // Einen Tag verpasst, aber Freeze verfügbar
                useFreeze()
                currentStreak += 1
            } else if daysDifference > 1 {
                // Streak verloren
                currentStreak = 1
            }
        } else {
            // Erster Check-in
            currentStreak = 1
        }
        
        // Längsten Streak aktualisieren
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastCheckIn = Date()
        checkedInToday = true
        
        // Freezes wöchentlich zurücksetzen
        resetFreezesIfNewWeek()
        
        saveData()
        
        // Achievement prüfen
        NotificationCenter.default.post(
            name: .streakUpdated,
            object: nil,
            userInfo: ["streak": currentStreak]
        )
    }
    
    /// Verwendet einen Streak-Freeze
    func useFreeze() {
        guard freezesAvailable > 0 else { return }
        freezesAvailable -= 1
        UserDefaults.standard.set(true, forKey: Keys.freezeUsedThisWeek)
        saveData()
    }
    
    /// Prüft, ob ein Meilenstein erreicht wurde
    func checkMilestone() -> Int? {
        if StreakManager.milestones.contains(currentStreak) {
            return currentStreak
        }
        return nil
    }
    
    /// Gibt den nächsten Meilenstein zurück
    var nextMilestone: Int {
        for milestone in StreakManager.milestones {
            if milestone > currentStreak {
                return milestone
            }
        }
        return currentStreak + 100
    }
    
    /// Fortschritt zum nächsten Meilenstein (0-1)
    var progressToNextMilestone: Double {
        let previous = StreakManager.milestones.last(where: { $0 < currentStreak }) ?? 0
        let next = nextMilestone
        let range = Double(next - previous)
        let progress = Double(currentStreak - previous)
        return min(progress / range, 1.0)
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        currentStreak = UserDefaults.standard.integer(forKey: Keys.currentStreak)
        longestStreak = UserDefaults.standard.integer(forKey: Keys.longestStreak)
        freezesAvailable = UserDefaults.standard.object(forKey: Keys.freezesAvailable) as? Int ?? 1
        
        if let lastCheckInTimestamp = UserDefaults.standard.object(forKey: Keys.lastCheckIn) as? TimeInterval {
            lastCheckIn = Date(timeIntervalSince1970: lastCheckInTimestamp)
        }
    }
    
    private func saveData() {
        UserDefaults.standard.set(currentStreak, forKey: Keys.currentStreak)
        UserDefaults.standard.set(longestStreak, forKey: Keys.longestStreak)
        UserDefaults.standard.set(freezesAvailable, forKey: Keys.freezesAvailable)
        
        if let lastCheckIn = lastCheckIn {
            UserDefaults.standard.set(lastCheckIn.timeIntervalSince1970, forKey: Keys.lastCheckIn)
        }
    }
    
    private func checkStreakStatus() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastCheckIn {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            
            // Prüfen ob heute schon eingecheckt
            if lastDay == today {
                checkedInToday = true
            }
            
            // Prüfen ob Streak in Gefahr
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if daysDifference >= 1 && !checkedInToday {
                showStreakWarning = true
            }
            
            // Streak verloren wenn mehr als 2 Tage vergangen
            if daysDifference > 2 || (daysDifference == 2 && freezesAvailable == 0) {
                currentStreak = 0
                saveData()
            }
        }
    }
    
    private func resetFreezesIfNewWeek() {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        let lastWeek = UserDefaults.standard.integer(forKey: "streak_lastWeek")
        
        if weekOfYear != lastWeek {
            freezesAvailable = 1
            UserDefaults.standard.set(weekOfYear, forKey: "streak_lastWeek")
            UserDefaults.standard.set(false, forKey: Keys.freezeUsedThisWeek)
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let streakUpdated = Notification.Name("streakUpdated")
}

// MARK: - Streak Card View

struct StreakDetailView: View {
    @EnvironmentObject var streakManager: StreakManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.orange, .red, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Streak Animation
                        VStack(spacing: 10) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .shadow(color: .orange, radius: 20)
                            
                            Text("\(streakManager.currentStreak)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Tage Streak")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 40)
                        
                        // Progress zum nächsten Meilenstein
                        VStack(spacing: 12) {
                            HStack {
                                Text("Nächster Meilenstein")
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text("\(streakManager.nextMilestone) Tage")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.3))
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(width: geometry.size.width * streakManager.progressToNextMilestone)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Stats
                        HStack(spacing: 20) {
                            StatCard(title: "Längster Streak", value: "\(streakManager.longestStreak)", icon: "trophy.fill")
                            StatCard(title: "Freezes", value: "\(streakManager.freezesAvailable)", icon: "snowflake")
                        }
                        .padding(.horizontal)
                        
                        // Meilensteine
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Meilensteine")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(StreakManager.milestones, id: \.self) { milestone in
                                MilestoneRow(
                                    days: milestone,
                                    isUnlocked: streakManager.longestStreak >= milestone,
                                    isCurrent: streakManager.currentStreak >= milestone
                                )
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Dein Streak")
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct MilestoneRow: View {
    let days: Int
    let isUnlocked: Bool
    let isCurrent: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isUnlocked ? .green : .white.opacity(0.5))
            
            Text("\(days) Tage")
                .foregroundColor(.white)
            
            Spacer()
            
            if isCurrent {
                Text("Erreicht!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 8)
    }
}
