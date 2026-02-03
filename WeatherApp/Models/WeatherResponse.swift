import Foundation

// MARK: - Haupt-Response Struktur

/// Hauptantwort von der WeatherAPI.com
struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
}

// MARK: - Location

/// Standortinformationen
struct Location: Codable {
    let name: String           // Stadtname
    let region: String         // Region/Bundesland
    let country: String        // Land
    let lat: Double            // Breitengrad
    let lon: Double            // Längengrad
    let localtime: String      // Lokale Zeit als String
    
    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case localtime
    }
}

// MARK: - Current Weather

/// Aktuelle Wetterdaten
struct CurrentWeather: Codable {
    let tempC: Double          // Temperatur in Celsius
    let tempF: Double          // Temperatur in Fahrenheit
    let isDay: Int             // 1 = Tag, 0 = Nacht
    let condition: WeatherConditionData
    let windKph: Double        // Windgeschwindigkeit km/h
    let windDir: String        // Windrichtung
    let humidity: Int          // Luftfeuchtigkeit in %
    let feelslikeC: Double     // Gefühlte Temperatur Celsius
    let feelslikeF: Double     // Gefühlte Temperatur Fahrenheit
    let uv: Double             // UV-Index
    let visKm: Double          // Sichtweite in km
    let pressureMb: Double     // Luftdruck in mbar
    
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case isDay = "is_day"
        case condition
        case windKph = "wind_kph"
        case windDir = "wind_dir"
        case humidity
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
        case uv
        case visKm = "vis_km"
        case pressureMb = "pressure_mb"
    }
}

// MARK: - Weather Condition Data

/// Wetterbedingung von der API
struct WeatherConditionData: Codable {
    let text: String           // Beschreibung (z.B. "Sonnig")
    let icon: String           // Icon-URL
    let code: Int              // Wetter-Code für Mapping
}

// MARK: - Forecast

/// Vorhersage-Container
struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

// MARK: - Forecast Day

/// Einzelner Vorhersage-Tag
struct ForecastDay: Codable, Identifiable {
    let date: String           // Datum als String (yyyy-MM-dd)
    let day: DayForecast       // Tagesvorhersage
    let hour: [HourForecast]   // Stündliche Vorhersage
    
    var id: String { date }
    
    /// Konvertiert den Datums-String zu einem Date-Objekt
    var dateObject: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}

// MARK: - Day Forecast

/// Tagesübersicht für Vorhersage
struct DayForecast: Codable {
    let maxtempC: Double       // Höchsttemperatur Celsius
    let maxtempF: Double       // Höchsttemperatur Fahrenheit
    let mintempC: Double       // Tiefsttemperatur Celsius
    let mintempF: Double       // Tiefsttemperatur Fahrenheit
    let avgtempC: Double       // Durchschnittstemperatur Celsius
    let avgtempF: Double       // Durchschnittstemperatur Fahrenheit
    let condition: WeatherConditionData
    let dailyChanceOfRain: Int // Regenwahrscheinlichkeit in %
    let dailyChanceOfSnow: Int // Schneewahrscheinlichkeit in %
    let avghumidity: Int       // Durchschnittliche Luftfeuchtigkeit
    let uv: Double             // UV-Index
    
    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case maxtempF = "maxtemp_f"
        case mintempC = "mintemp_c"
        case mintempF = "mintemp_f"
        case avgtempC = "avgtemp_c"
        case avgtempF = "avgtemp_f"
        case condition
        case dailyChanceOfRain = "daily_chance_of_rain"
        case dailyChanceOfSnow = "daily_chance_of_snow"
        case avghumidity
        case uv
    }
}

// MARK: - Hour Forecast

/// Stündliche Vorhersage
struct HourForecast: Codable, Identifiable {
    let time: String           // Zeit als String
    let tempC: Double          // Temperatur Celsius
    let tempF: Double          // Temperatur Fahrenheit
    let condition: WeatherConditionData
    let chanceOfRain: Int      // Regenwahrscheinlichkeit
    let isDay: Int             // Tag oder Nacht
    
    var id: String { time }
    
    /// Extrahiert nur die Stunde aus dem Zeit-String
    var hourString: String {
        let components = time.components(separatedBy: " ")
        if components.count > 1 {
            let timeComponents = components[1].components(separatedBy: ":")
            if let hour = timeComponents.first {
                return "\(hour):00"
            }
        }
        return time
    }
    
    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case tempF = "temp_f"
        case condition
        case chanceOfRain = "chance_of_rain"
        case isDay = "is_day"
    }
}

// MARK: - API Error Response

/// Fehlerantwort von der API
struct APIErrorResponse: Codable {
    let error: APIError
}

struct APIError: Codable {
    let code: Int
    let message: String
}
