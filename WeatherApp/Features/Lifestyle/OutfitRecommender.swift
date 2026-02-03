import Foundation
import SwiftUI

// MARK: - Outfit Recommendation Model

struct OutfitRecommendation {
    let emoji: String
    let shortTip: String
    let fullDescription: String
    let items: [OutfitItem]
    let style: OutfitStyle
}

struct OutfitItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let isRequired: Bool
}

enum OutfitStyle: String {
    case summer = "Sommer-Look"
    case spring = "Frühlings-Outfit"
    case autumn = "Herbst-Style"
    case winter = "Winter-Outfit"
    case rainy = "Regenfest"
    case casual = "Casual"
}

// MARK: - Outfit Recommender

final class OutfitRecommender {
    
    static let shared = OutfitRecommender()
    
    private init() {}
    
    /// Generiert eine Outfit-Empfehlung basierend auf den Wetterdaten
    func getRecommendation(for weather: WeatherResponse?) -> OutfitRecommendation {
        guard let weather = weather else {
            return defaultRecommendation
        }
        
        let temp = weather.current.tempC
        let condition = WeatherCondition(code: weather.current.condition.code)
        let isRainy = [.rain, .heavyRain, .thunderstorm, .sleet].contains(condition)
        let uvIndex = weather.current.uv
        let windSpeed = weather.current.windKph
        
        // Temperatur-basierte Basis-Empfehlung
        var items: [OutfitItem] = []
        var emoji = "👕"
        var shortTip = ""
        var fullDescription = ""
        var style: OutfitStyle = .casual
        
        // Temperatur-Kategorien
        if temp >= 28 {
            // Sehr heiß
            emoji = "☀️"
            shortTip = "Leicht & luftig"
            style = .summer
            items = [
                OutfitItem(name: "T-Shirt / Tank Top", icon: "tshirt.fill", isRequired: true),
                OutfitItem(name: "Shorts / Kurzer Rock", icon: "figure.walk", isRequired: true),
                OutfitItem(name: "Sandalen", icon: "shoe.fill", isRequired: true),
                OutfitItem(name: "Sonnenbrille", icon: "sunglasses", isRequired: uvIndex > 3),
                OutfitItem(name: "Sonnencreme", icon: "sun.max.fill", isRequired: uvIndex > 5),
                OutfitItem(name: "Hut/Cap", icon: "hat.widebrim.fill", isRequired: uvIndex > 6),
            ]
            fullDescription = "Heute wird es richtig heiß! Wähle luftige, atmungsaktive Kleidung. Vergiss nicht den Sonnenschutz!"
            
        } else if temp >= 20 {
            // Warm
            emoji = "🌤️"
            shortTip = "Perfektes T-Shirt Wetter"
            style = .summer
            items = [
                OutfitItem(name: "T-Shirt", icon: "tshirt.fill", isRequired: true),
                OutfitItem(name: "Jeans / Chinos", icon: "figure.walk", isRequired: true),
                OutfitItem(name: "Sneaker", icon: "shoe.fill", isRequired: true),
                OutfitItem(name: "Leichte Jacke", icon: "jacket.fill", isRequired: false),
                OutfitItem(name: "Sonnenbrille", icon: "sunglasses", isRequired: uvIndex > 3),
            ]
            fullDescription = "Angenehme Temperaturen! Ein T-Shirt reicht tagsüber, pack aber eine leichte Jacke für den Abend ein."
            
        } else if temp >= 15 {
            // Mild
            emoji = "🍃"
            shortTip = "Zwiebel-Look"
            style = .spring
            items = [
                OutfitItem(name: "Longsleeve / Hemd", icon: "tshirt.fill", isRequired: true),
                OutfitItem(name: "Jeans", icon: "figure.walk", isRequired: true),
                OutfitItem(name: "Sneaker", icon: "shoe.fill", isRequired: true),
                OutfitItem(name: "Leichte Jacke / Hoodie", icon: "jacket.fill", isRequired: true),
            ]
            fullDescription = "Typisches Übergangswetter - der Zwiebel-Look ist dein Freund! Mehrere Schichten, die du an- und ausziehen kannst."
            
        } else if temp >= 8 {
            // Kühl
            emoji = "🍂"
            shortTip = "Jacke nicht vergessen!"
            style = .autumn
            items = [
                OutfitItem(name: "Pullover / Hoodie", icon: "tshirt.fill", isRequired: true),
                OutfitItem(name: "Jeans", icon: "figure.walk", isRequired: true),
                OutfitItem(name: "Jacke", icon: "jacket.fill", isRequired: true),
                OutfitItem(name: "Geschlossene Schuhe", icon: "shoe.fill", isRequired: true),
                OutfitItem(name: "Leichter Schal", icon: "scarf.fill", isRequired: windSpeed > 20),
            ]
            fullDescription = "Es wird frisch! Eine wärmere Jacke und ein Pullover sind heute Pflicht."
            
        } else if temp >= 0 {
            // Kalt
            emoji = "🧥"
            shortTip = "Warm einpacken!"
            style = .winter
            items = [
                OutfitItem(name: "Warmer Pullover", icon: "tshirt.fill", isRequired: true),
                OutfitItem(name: "Winterjacke", icon: "jacket.fill", isRequired: true),
                OutfitItem(name: "Warme Hose", icon: "figure.walk", isRequired: true),
                OutfitItem(name: "Stiefel / Winterschuhe", icon: "shoe.fill", isRequired: true),
                OutfitItem(name: "Mütze", icon: "hat.fill", isRequired: true),
                OutfitItem(name: "Schal", icon: "scarf.fill", isRequired: true),
                OutfitItem(name: "Handschuhe", icon: "hand.raised.fill", isRequired: temp < 3),
            ]
            fullDescription = "Brrrr, es ist kalt! Pack dich warm ein mit Mütze und Schal. Handschuhe sind auch keine schlechte Idee."
            
        } else {
            // Sehr kalt / Frost
            emoji = "❄️"
            shortTip = "Maximum Wärme!"
            style = .winter
            items = [
                OutfitItem(name: "Thermounterwäsche", icon: "figure.walk", isRequired: true),
                OutfitItem(name: "Dicker Pullover", icon: "tshirt.fill", isRequired: true),
                OutfitItem(name: "Wintermantel", icon: "jacket.fill", isRequired: true),
                OutfitItem(name: "Gefütterte Hose", icon: "figure.walk", isRequired: true),
                OutfitItem(name: "Winterstiefel", icon: "shoe.fill", isRequired: true),
                OutfitItem(name: "Warme Mütze", icon: "hat.fill", isRequired: true),
                OutfitItem(name: "Schal", icon: "scarf.fill", isRequired: true),
                OutfitItem(name: "Gefütterte Handschuhe", icon: "hand.raised.fill", isRequired: true),
            ]
            fullDescription = "Frostiges Wetter! Zieh dich in Schichten an und vergiss keine Extremitäten. Thermounterwäsche ist dein Freund!"
        }
        
        // Regen-Anpassungen
        if isRainy {
            emoji = "🌧️"
            shortTip = "Regenschirm einpacken!"
            style = .rainy
            
            // Füge Regen-Items hinzu
            items.insert(OutfitItem(name: "Regenjacke", icon: "cloud.rain.fill", isRequired: true), at: 0)
            items.append(OutfitItem(name: "Regenschirm", icon: "umbrella.fill", isRequired: true))
            items.append(OutfitItem(name: "Wasserfeste Schuhe", icon: "shoe.fill", isRequired: condition == .heavyRain))
            
            fullDescription = "Regen ist angesagt! Wasserfeste Kleidung und ein Regenschirm sind heute Pflicht. " + fullDescription
        }
        
        // Wind-Anpassungen
        if windSpeed > 30 && !items.contains(where: { $0.name.contains("Schal") }) {
            items.append(OutfitItem(name: "Winddichte Jacke", icon: "wind", isRequired: true))
            fullDescription += " Starker Wind erwartet - achte auf winddichte Kleidung!"
        }
        
        return OutfitRecommendation(
            emoji: emoji,
            shortTip: shortTip,
            fullDescription: fullDescription,
            items: items,
            style: style
        )
    }
    
    private var defaultRecommendation: OutfitRecommendation {
        OutfitRecommendation(
            emoji: "👕",
            shortTip: "Wetterdaten laden...",
            fullDescription: "Lade Wetterdaten für personalisierte Empfehlungen.",
            items: [],
            style: .casual
        )
    }
}

// MARK: - Outfit Detail View

struct OutfitDetailView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    
    var recommendation: OutfitRecommendation {
        OutfitRecommender.shared.getRecommendation(for: viewModel.weatherResponse)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund basierend auf Style
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header mit Emoji
                        VStack(spacing: 10) {
                            Text(recommendation.emoji)
                                .font(.system(size: 80))
                            
                            Text(recommendation.style.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(recommendation.shortTip)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Wetter-Info
                        if let weather = viewModel.weatherResponse {
                            HStack(spacing: 20) {
                                WeatherInfoPill(icon: "thermometer", value: "\(Int(weather.current.tempC))°")
                                WeatherInfoPill(icon: "humidity.fill", value: "\(weather.current.humidity)%")
                                WeatherInfoPill(icon: "wind", value: "\(Int(weather.current.windKph)) km/h")
                            }
                        }
                        
                        // Beschreibung
                        Text(recommendation.fullDescription)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Outfit Items
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Empfohlene Items")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(recommendation.items) { item in
                                OutfitItemRow(item: item)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Aktivitäts-Vorschläge
                        ActivitySuggestionsCard()
                            .environmentObject(viewModel)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Outfit des Tages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        switch recommendation.style {
        case .summer:
            return LinearGradient(colors: [.orange, .yellow, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .spring:
            return LinearGradient(colors: [.green, .mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .autumn:
            return LinearGradient(colors: [.orange, .brown, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .winter:
            return LinearGradient(colors: [.blue, .indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rainy:
            return LinearGradient(colors: [.gray, .blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .casual:
            return LinearGradient(colors: [.blue, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct WeatherInfoPill: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct OutfitItemRow: View {
    let item: OutfitItem
    
    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30)
            
            Text(item.name)
                .foregroundColor(.white)
            
            Spacer()
            
            if item.isRequired {
                Text("Empfohlen")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Activity Suggestions

struct ActivitySuggestionsCard: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var suggestions: [ActivitySuggestion] {
        ActivitySuggestion.getSuggestions(for: viewModel.weatherResponse)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Perfekter Tag für...")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(suggestions) { suggestion in
                HStack {
                    Image(systemName: suggestion.icon)
                        .font(.title2)
                        .foregroundColor(suggestion.color)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading) {
                        Text(suggestion.activity)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text(suggestion.reason)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Matching Score
                    Text("\(suggestion.matchScore)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct ActivitySuggestion: Identifiable {
    let id = UUID()
    let activity: String
    let icon: String
    let color: Color
    let reason: String
    let matchScore: Int
    
    static func getSuggestions(for weather: WeatherResponse?) -> [ActivitySuggestion] {
        guard let weather = weather else { return [] }
        
        var suggestions: [ActivitySuggestion] = []
        let temp = weather.current.tempC
        let condition = WeatherCondition(code: weather.current.condition.code)
        let isRainy = [.rain, .heavyRain, .thunderstorm].contains(condition)
        let isSunny = [.sunny, .clear, .partlyCloudy].contains(condition)
        
        if isSunny && temp >= 15 && temp <= 25 {
            suggestions.append(ActivitySuggestion(
                activity: "Joggen",
                icon: "figure.run",
                color: .orange,
                reason: "Ideale Lauftemperatur",
                matchScore: 95
            ))
        }
        
        if isSunny && temp >= 18 {
            suggestions.append(ActivitySuggestion(
                activity: "Picknick im Park",
                icon: "leaf.fill",
                color: .green,
                reason: "Perfektes Wetter für draußen",
                matchScore: 90
            ))
        }
        
        if isSunny && temp >= 20 && temp <= 30 {
            suggestions.append(ActivitySuggestion(
                activity: "Fahrradfahren",
                icon: "bicycle",
                color: .blue,
                reason: "Angenehm zum Radeln",
                matchScore: 88
            ))
        }
        
        if isRainy || temp < 10 {
            suggestions.append(ActivitySuggestion(
                activity: "Netflix & Chill",
                icon: "tv.fill",
                color: .red,
                reason: "Perfektes Couch-Wetter",
                matchScore: 95
            ))
            
            suggestions.append(ActivitySuggestion(
                activity: "Café besuchen",
                icon: "cup.and.saucer.fill",
                color: .brown,
                reason: "Gemütlich bei einem Kaffee",
                matchScore: 85
            ))
        }
        
        if condition == .sunny || condition == .partlyCloudy {
            suggestions.append(ActivitySuggestion(
                activity: "Fotografie (Golden Hour)",
                icon: "camera.fill",
                color: .yellow,
                reason: "Tolles Licht für Fotos",
                matchScore: 82
            ))
        }
        
        return Array(suggestions.prefix(4))
    }
}
