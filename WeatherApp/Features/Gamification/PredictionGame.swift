import Foundation
import SwiftUI

// MARK: - Prediction Model

struct WeatherPrediction: Codable, Identifiable {
    let id: UUID
    let date: Date
    let predictedCondition: String
    let predictedTempRange: TemperatureRange
    let actualCondition: String?
    let actualTemp: Double?
    var isCorrect: Bool?
    var points: Int?
    
    struct TemperatureRange: Codable {
        let min: Int
        let max: Int
    }
}

// MARK: - Prediction Game Manager

@MainActor
final class PredictionGameManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var predictions: [WeatherPrediction] = []
    @Published var totalPoints: Int = 0
    @Published var correctPredictions: Int = 0
    @Published var totalPredictions: Int = 0
    @Published var currentStreak: Int = 0
    @Published var hasPredictedToday: Bool = false
    
    // MARK: - Computed Properties
    
    var accuracy: Double {
        guard totalPredictions > 0 else { return 0 }
        return Double(correctPredictions) / Double(totalPredictions) * 100
    }
    
    var rank: String {
        switch accuracy {
        case 80...100: return "Wetter-Guru"
        case 60..<80: return "Wetter-Profi"
        case 40..<60: return "Wetter-Kenner"
        case 20..<40: return "Wetter-Lehrling"
        default: return "Wetter-Anfänger"
        }
    }
    
    // MARK: - Initialization
    
    init() {
        loadData()
        checkTodaysPrediction()
    }
    
    // MARK: - Public Methods
    
    /// Erstellt eine neue Vorhersage für morgen
    func makePrediction(condition: String, tempRange: WeatherPrediction.TemperatureRange) {
        let prediction = WeatherPrediction(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            predictedCondition: condition,
            predictedTempRange: tempRange,
            actualCondition: nil,
            actualTemp: nil,
            isCorrect: nil,
            points: nil
        )
        
        predictions.append(prediction)
        hasPredictedToday = true
        totalPredictions += 1
        
        saveData()
    }
    
    /// Überprüft gestrige Vorhersage mit dem tatsächlichen Wetter
    func verifyPrediction(actualCondition: String, actualTemp: Double) {
        // Finde die Vorhersage von gestern
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayStart = Calendar.current.startOfDay(for: yesterday)
        
        guard let index = predictions.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: yesterdayStart) && $0.isCorrect == nil
        }) else { return }
        
        var prediction = predictions[index]
        prediction.actualCondition = actualCondition
        prediction.actualTemp = actualTemp
        
        // Punkte berechnen
        var points = 0
        
        // Bedingung richtig? (50 Punkte)
        let conditionCorrect = isConditionMatch(predicted: prediction.predictedCondition, actual: actualCondition)
        if conditionCorrect {
            points += 50
        }
        
        // Temperatur richtig? (50 Punkte)
        let tempCorrect = Int(actualTemp) >= prediction.predictedTempRange.min &&
                          Int(actualTemp) <= prediction.predictedTempRange.max
        if tempCorrect {
            points += 50
        }
        
        // Bonus für beide richtig
        if conditionCorrect && tempCorrect {
            points += 25
            currentStreak += 1
            
            // Streak-Bonus
            if currentStreak >= 3 {
                points += currentStreak * 5
            }
        } else {
            currentStreak = 0
        }
        
        prediction.isCorrect = conditionCorrect && tempCorrect
        prediction.points = points
        
        if prediction.isCorrect == true {
            correctPredictions += 1
        }
        
        totalPoints += points
        predictions[index] = prediction
        
        saveData()
        
        // Achievement prüfen
        if totalPredictions >= 10 {
            NotificationCenter.default.post(
                name: .predictionMilestone,
                object: nil,
                userInfo: ["count": totalPredictions, "accuracy": accuracy]
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func isConditionMatch(predicted: String, actual: String) -> Bool {
        // Vereinfachte Kategorien für Matching
        let sunnyKeywords = ["sonnig", "klar", "heiter", "sunny", "clear"]
        let cloudyKeywords = ["bewölkt", "wolkig", "bedeckt", "cloudy", "overcast"]
        let rainyKeywords = ["regen", "schauer", "rain", "drizzle"]
        let snowKeywords = ["schnee", "snow", "sleet"]
        let stormKeywords = ["gewitter", "sturm", "thunder", "storm"]
        
        let predictedLower = predicted.lowercased()
        let actualLower = actual.lowercased()
        
        // Prüfe Kategorie-Match
        if sunnyKeywords.contains(where: { predictedLower.contains($0) }) &&
           sunnyKeywords.contains(where: { actualLower.contains($0) }) {
            return true
        }
        if cloudyKeywords.contains(where: { predictedLower.contains($0) }) &&
           cloudyKeywords.contains(where: { actualLower.contains($0) }) {
            return true
        }
        if rainyKeywords.contains(where: { predictedLower.contains($0) }) &&
           rainyKeywords.contains(where: { actualLower.contains($0) }) {
            return true
        }
        if snowKeywords.contains(where: { predictedLower.contains($0) }) &&
           snowKeywords.contains(where: { actualLower.contains($0) }) {
            return true
        }
        if stormKeywords.contains(where: { predictedLower.contains($0) }) &&
           stormKeywords.contains(where: { actualLower.contains($0) }) {
            return true
        }
        
        return false
    }
    
    private func checkTodaysPrediction() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        hasPredictedToday = predictions.contains {
            Calendar.current.isDate($0.date, inSameDayAs: tomorrow)
        }
    }
    
    private func loadData() {
        totalPoints = UserDefaults.standard.integer(forKey: "prediction_points")
        correctPredictions = UserDefaults.standard.integer(forKey: "prediction_correct")
        totalPredictions = UserDefaults.standard.integer(forKey: "prediction_total")
        currentStreak = UserDefaults.standard.integer(forKey: "prediction_streak")
        
        if let data = UserDefaults.standard.data(forKey: "predictions"),
           let saved = try? JSONDecoder().decode([WeatherPrediction].self, from: data) {
            predictions = saved
        }
    }
    
    private func saveData() {
        UserDefaults.standard.set(totalPoints, forKey: "prediction_points")
        UserDefaults.standard.set(correctPredictions, forKey: "prediction_correct")
        UserDefaults.standard.set(totalPredictions, forKey: "prediction_total")
        UserDefaults.standard.set(currentStreak, forKey: "prediction_streak")
        
        if let data = try? JSONEncoder().encode(predictions) {
            UserDefaults.standard.set(data, forKey: "predictions")
        }
    }
}

extension Notification.Name {
    static let predictionMilestone = Notification.Name("predictionMilestone")
}

// MARK: - Prediction Game View

struct PredictionGameView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @StateObject private var gameManager = PredictionGameManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCondition: String = "Sonnig"
    @State private var selectedTempMin: Int = 15
    @State private var selectedTempMax: Int = 20
    @State private var showResult = false
    
    let conditions = ["Sonnig", "Bewölkt", "Regen", "Gewitter", "Schnee"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.purple, .blue, .indigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Stats Header
                        StatsHeaderView(gameManager: gameManager)
                        
                        if gameManager.hasPredictedToday {
                            // Bereits vorhergesagt
                            AlreadyPredictedView()
                        } else {
                            // Vorhersage-Formular
                            PredictionFormView(
                                selectedCondition: $selectedCondition,
                                selectedTempMin: $selectedTempMin,
                                selectedTempMax: $selectedTempMax,
                                conditions: conditions
                            )
                            
                            // Submit Button
                            Button {
                                submitPrediction()
                            } label: {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Vorhersage abgeben")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                            }
                            .padding(.horizontal)
                        }
                        
                        // History
                        if !gameManager.predictions.isEmpty {
                            PredictionHistoryView(predictions: gameManager.predictions)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Wetter-Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .alert("Vorhersage abgegeben!", isPresented: $showResult) {
                Button("OK") { }
            } message: {
                Text("Deine Vorhersage für morgen wurde gespeichert. Komm morgen wieder, um zu sehen, ob du richtig lagst!")
            }
        }
    }
    
    private func submitPrediction() {
        gameManager.makePrediction(
            condition: selectedCondition,
            tempRange: .init(min: selectedTempMin, max: selectedTempMax)
        )
        showResult = true
    }
}

struct StatsHeaderView: View {
    @ObservedObject var gameManager: PredictionGameManager
    
    var body: some View {
        VStack(spacing: 15) {
            // Rang
            Text(gameManager.rank)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Stats Grid
            HStack(spacing: 20) {
                StatItem(value: "\(gameManager.totalPoints)", label: "Punkte", icon: "star.fill", color: .yellow)
                StatItem(value: String(format: "%.0f%%", gameManager.accuracy), label: "Genauigkeit", icon: "target", color: .green)
                StatItem(value: "\(gameManager.currentStreak)", label: "Streak", icon: "flame.fill", color: .orange)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct AlreadyPredictedView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Du hast heute bereits vorhergesagt!")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Komm morgen wieder, um das Ergebnis zu sehen und eine neue Vorhersage zu machen.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct PredictionFormView: View {
    @Binding var selectedCondition: String
    @Binding var selectedTempMin: Int
    @Binding var selectedTempMax: Int
    let conditions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Wie wird das Wetter morgen?")
                .font(.headline)
                .foregroundColor(.white)
            
            // Condition Picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Wetterbedingung")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(conditions, id: \.self) { condition in
                            ConditionButton(
                                condition: condition,
                                isSelected: selectedCondition == condition
                            ) {
                                selectedCondition = condition
                            }
                        }
                    }
                }
            }
            
            // Temperature Range
            VStack(alignment: .leading, spacing: 10) {
                Text("Temperatur-Bereich")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack {
                    VStack {
                        Text("Min")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Picker("Min", selection: $selectedTempMin) {
                            ForEach(-10..<40, id: \.self) { temp in
                                Text("\(temp)°").tag(temp)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 100)
                        .clipped()
                    }
                    
                    Text("bis")
                        .foregroundColor(.white)
                    
                    VStack {
                        Text("Max")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Picker("Max", selection: $selectedTempMax) {
                            ForEach(-10..<40, id: \.self) { temp in
                                Text("\(temp)°").tag(temp)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 100)
                        .clipped()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct ConditionButton: View {
    let condition: String
    let isSelected: Bool
    let action: () -> Void
    
    var icon: String {
        switch condition {
        case "Sonnig": return "sun.max.fill"
        case "Bewölkt": return "cloud.fill"
        case "Regen": return "cloud.rain.fill"
        case "Gewitter": return "cloud.bolt.fill"
        case "Schnee": return "cloud.snow.fill"
        default: return "questionmark"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.title2)
                Text(condition)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding()
            .background(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct PredictionHistoryView: View {
    let predictions: [WeatherPrediction]
    
    var recentPredictions: [WeatherPrediction] {
        Array(predictions.suffix(5).reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Letzte Vorhersagen")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(recentPredictions) { prediction in
                PredictionHistoryRow(prediction: prediction)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct PredictionHistoryRow: View {
    let prediction: WeatherPrediction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(prediction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(prediction.predictedCondition), \(prediction.predictedTempRange.min)-\(prediction.predictedTempRange.max)°")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            if let isCorrect = prediction.isCorrect {
                HStack(spacing: 5) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    if let points = prediction.points {
                        Text("+\(points)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
            } else {
                Text("Ausstehend")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 5)
    }
}
