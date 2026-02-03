import Foundation

enum Constants {
    /// WeatherAPI.com API-Schlüssel
    /// Registriere dich unter https://www.weatherapi.com/ für einen kostenlosen Schlüssel
    static let apiKey = "DEIN_API_KEY_HIER"  // Trage hier deinen WeatherAPI.com Key ein
    
    /// Basis-URL für WeatherAPI.com
    static let baseURL = "https://api.weatherapi.com/v1"
    
    /// Forecast Endpoint mit 5-Tage-Vorhersage
    static let forecastEndpoint = "/forecast.json"
    
    /// Anzahl der Vorhersage-Tage
    static let forecastDays = 5
    
    /// Standardsprache für API-Antworten
    static let apiLanguage = "de"
    
    /// Standard-Stadt falls Standort nicht verfügbar
    static let defaultCity = "Berlin"
    
    /// UserDefaults Keys
    enum UserDefaultsKeys {
        static let useCelsius = "useCelsius"
        static let lastSearchedCity = "lastSearchedCity"
    }
}
