import Foundation
import SwiftUI

/// Enum für verschiedene Wetterbedingungen mit zugehörigen Icons und Farben
enum WeatherCondition: CaseIterable {
    case sunny
    case partlyCloudy
    case cloudy
    case overcast
    case mist
    case rain
    case heavyRain
    case thunderstorm
    case snow
    case sleet
    case fog
    case clear
    case unknown
    
    // MARK: - Initialisierung aus API-Code
    
    /// Erstellt eine WeatherCondition aus dem API-Wetter-Code
    /// Referenz: https://www.weatherapi.com/docs/weather_conditions.json
    init(code: Int, isDay: Bool = true) {
        switch code {
        case 1000:
            self = isDay ? .sunny : .clear
        case 1003:
            self = .partlyCloudy
        case 1006:
            self = .cloudy
        case 1009:
            self = .overcast
        case 1030, 1135, 1147:
            self = .fog
        case 1063, 1150, 1153, 1180, 1183, 1186, 1189, 1240:
            self = .rain
        case 1192, 1195, 1243, 1246:
            self = .heavyRain
        case 1087, 1273, 1276, 1279, 1282:
            self = .thunderstorm
        case 1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258:
            self = .snow
        case 1069, 1072, 1168, 1171, 1198, 1201, 1204, 1207, 1237, 1249, 1252, 1261, 1264:
            self = .sleet
        default:
            self = .unknown
        }
    }
    
    // MARK: - SF Symbol Name
    
    /// SF Symbol für die Wetterbedingung
    var sfSymbolName: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .clear:
            return "moon.stars.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .cloudy:
            return "cloud.fill"
        case .overcast:
            return "smoke.fill"
        case .mist, .fog:
            return "cloud.fog.fill"
        case .rain:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .snow:
            return "cloud.snow.fill"
        case .sleet:
            return "cloud.sleet.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    // MARK: - Farbverlauf
    
    /// Farben für den Hintergrund-Gradienten
    var gradientColors: [Color] {
        switch self {
        case .sunny:
            return [
                Color(red: 0.99, green: 0.80, blue: 0.18),  // Gelb
                Color(red: 1.0, green: 0.58, blue: 0.0),    // Orange
                Color(red: 0.0, green: 0.68, blue: 0.94)    // Blau
            ]
        case .clear:
            return [
                Color(red: 0.07, green: 0.13, blue: 0.26),  // Dunkelblau
                Color(red: 0.16, green: 0.24, blue: 0.39),  // Mittelblau
                Color(red: 0.05, green: 0.05, blue: 0.15)   // Fast Schwarz
            ]
        case .partlyCloudy:
            return [
                Color(red: 0.53, green: 0.81, blue: 0.98),  // Hellblau
                Color(red: 0.68, green: 0.85, blue: 0.90),  // Sehr hellblau
                Color(red: 0.0, green: 0.55, blue: 0.80)    // Blau
            ]
        case .cloudy, .overcast:
            return [
                Color(red: 0.55, green: 0.58, blue: 0.62),  // Grau
                Color(red: 0.70, green: 0.75, blue: 0.80),  // Hellgrau
                Color(red: 0.45, green: 0.55, blue: 0.65)   // Blaugrau
            ]
        case .mist, .fog:
            return [
                Color(red: 0.75, green: 0.78, blue: 0.82),  // Hellgrau
                Color(red: 0.85, green: 0.88, blue: 0.90),  // Sehr hellgrau
                Color(red: 0.65, green: 0.70, blue: 0.75)   // Mittelgrau
            ]
        case .rain:
            return [
                Color(red: 0.25, green: 0.35, blue: 0.50),  // Dunkelblau
                Color(red: 0.40, green: 0.50, blue: 0.60),  // Blaugrau
                Color(red: 0.30, green: 0.40, blue: 0.55)   // Mittelblau
            ]
        case .heavyRain:
            return [
                Color(red: 0.15, green: 0.22, blue: 0.35),  // Sehr dunkelblau
                Color(red: 0.25, green: 0.35, blue: 0.45),  // Dunkelblau
                Color(red: 0.20, green: 0.28, blue: 0.40)   // Dunkelblaugrau
            ]
        case .thunderstorm:
            return [
                Color(red: 0.15, green: 0.15, blue: 0.25),  // Dunkelviolett
                Color(red: 0.25, green: 0.20, blue: 0.35),  // Violettgrau
                Color(red: 0.10, green: 0.10, blue: 0.20)   // Fast schwarz
            ]
        case .snow:
            return [
                Color(red: 0.90, green: 0.95, blue: 1.0),   // Weißblau
                Color(red: 0.80, green: 0.88, blue: 0.95),  // Hellblau
                Color(red: 0.70, green: 0.82, blue: 0.92)   // Blau
            ]
        case .sleet:
            return [
                Color(red: 0.65, green: 0.75, blue: 0.85),  // Blaugrau
                Color(red: 0.75, green: 0.82, blue: 0.88),  // Hellblaugrau
                Color(red: 0.55, green: 0.65, blue: 0.78)   // Mittelblau
            ]
        case .unknown:
            return [
                Color(red: 0.45, green: 0.55, blue: 0.70),  // Blaugrau
                Color(red: 0.55, green: 0.65, blue: 0.75),  // Hellblaugrau
                Color(red: 0.35, green: 0.45, blue: 0.60)   // Dunkelblau
            ]
        }
    }
    
    // MARK: - Icon-Farbe
    
    /// Farbe für das Wetter-Icon
    var iconColor: Color {
        switch self {
        case .sunny:
            return .yellow
        case .clear:
            return .white
        case .partlyCloudy:
            return .orange
        case .cloudy, .overcast:
            return .gray
        case .mist, .fog:
            return Color(white: 0.7)
        case .rain, .heavyRain:
            return .blue
        case .thunderstorm:
            return .purple
        case .snow, .sleet:
            return .cyan
        case .unknown:
            return .gray
        }
    }
    
    // MARK: - Beschreibung
    
    /// Deutsche Beschreibung der Wetterbedingung
    var description: String {
        switch self {
        case .sunny:
            return "Sonnig"
        case .clear:
            return "Klar"
        case .partlyCloudy:
            return "Teilweise bewölkt"
        case .cloudy:
            return "Bewölkt"
        case .overcast:
            return "Bedeckt"
        case .mist:
            return "Neblig"
        case .fog:
            return "Nebel"
        case .rain:
            return "Regen"
        case .heavyRain:
            return "Starkregen"
        case .thunderstorm:
            return "Gewitter"
        case .snow:
            return "Schnee"
        case .sleet:
            return "Schneeregen"
        case .unknown:
            return "Unbekannt"
        }
    }
}
