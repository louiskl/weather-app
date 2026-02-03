import Foundation
import SwiftUI
import Combine

/// Haupt-ViewModel für die Wetter-App
@MainActor
final class WeatherViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Aktuelle Wetterdaten
    @Published var weatherResponse: WeatherResponse?
    
    /// Zeigt an, ob gerade Daten geladen werden
    @Published var isLoading = false
    
    /// Fehlermeldung falls vorhanden
    @Published var errorMessage: String?
    
    /// Zeigt an, ob ein Fehler aufgetreten ist
    @Published var showError = false
    
    /// Aktueller Suchtext
    @Published var searchText = ""
    
    /// Zeigt Celsius (true) oder Fahrenheit (false) an
    @Published var useCelsius: Bool {
        didSet {
            UserDefaults.standard.set(useCelsius, forKey: Constants.UserDefaultsKeys.useCelsius)
        }
    }
    
    /// Letzte gesuchte Stadt
    @Published var lastSearchedCity: String? {
        didSet {
            if let city = lastSearchedCity {
                UserDefaults.standard.set(city, forKey: Constants.UserDefaultsKeys.lastSearchedCity)
            }
        }
    }
    
    // MARK: - Dependencies
    
    private let weatherService: WeatherServiceProtocol
    let locationManager: LocationManager
    
    // MARK: - Computed Properties
    
    /// Aktuelle Wetterbedingung
    var currentCondition: WeatherCondition {
        guard let weather = weatherResponse?.current else {
            return .unknown
        }
        return WeatherCondition(code: weather.condition.code, isDay: weather.isDay == 1)
    }
    
    /// Aktuelle Temperatur formatiert
    var currentTemperature: String {
        guard let weather = weatherResponse?.current else { return "--" }
        let temp = useCelsius ? weather.tempC : weather.tempF
        return "\(temp.temperatureString)°"
    }
    
    /// Gefühlte Temperatur formatiert
    var feelsLikeTemperature: String {
        guard let weather = weatherResponse?.current else { return "--" }
        let temp = useCelsius ? weather.feelslikeC : weather.feelslikeF
        return "Gefühlt \(temp.temperatureString)°"
    }
    
    /// Temperatureinheit
    var temperatureUnit: String {
        useCelsius ? "C" : "F"
    }
    
    /// Stadtname
    var cityName: String {
        weatherResponse?.location.name ?? Constants.defaultCity
    }
    
    /// Land
    var countryName: String {
        weatherResponse?.location.country ?? ""
    }
    
    /// Vollständiger Standortname
    var locationName: String {
        guard let location = weatherResponse?.location else { return "" }
        if location.region.isEmpty {
            return "\(location.name), \(location.country)"
        }
        return "\(location.name), \(location.region)"
    }
    
    /// Wetterbeschreibung
    var weatherDescription: String {
        weatherResponse?.current.condition.text ?? "Unbekannt"
    }
    
    /// Luftfeuchtigkeit
    var humidity: String {
        guard let weather = weatherResponse?.current else { return "--%" }
        return "\(weather.humidity)%"
    }
    
    /// Windgeschwindigkeit
    var windSpeed: String {
        guard let weather = weatherResponse?.current else { return "-- km/h" }
        return "\(Int(weather.windKph)) km/h"
    }
    
    /// UV-Index
    var uvIndex: String {
        guard let weather = weatherResponse?.current else { return "--" }
        return String(format: "%.0f", weather.uv)
    }
    
    /// 5-Tage-Vorhersage (ohne heute)
    var forecast: [ForecastDay] {
        guard let forecast = weatherResponse?.forecast.forecastday else { return [] }
        // Überspringe den ersten Tag (heute) falls mehr als ein Tag vorhanden
        return Array(forecast.dropFirst())
    }
    
    /// Heutige Vorhersage
    var todayForecast: ForecastDay? {
        weatherResponse?.forecast.forecastday.first
    }
    
    /// Stündliche Vorhersage für heute
    var hourlyForecast: [HourForecast] {
        guard let today = todayForecast else { return [] }
        // Filtere nur zukünftige Stunden
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        return today.hour.filter { hourForecast in
            if let hourString = hourForecast.time.components(separatedBy: " ").last?.components(separatedBy: ":").first,
               let hour = Int(hourString) {
                return hour >= currentHour
            }
            return false
        }
    }
    
    // MARK: - Initialization
    
    init(weatherService: WeatherServiceProtocol = WeatherService.shared,
         locationManager: LocationManager = LocationManager()) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        
        // Gespeicherte Einstellungen laden
        self.useCelsius = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.useCelsius) as? Bool ?? true
        self.lastSearchedCity = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.lastSearchedCity)
    }
    
    // MARK: - Public Methods
    
    /// Lädt das Wetter für eine bestimmte Stadt
    /// - Parameter city: Name der Stadt
    func fetchWeather(for city: String) async {
        let trimmedCity = city.trimmed
        guard !trimmedCity.isEmpty else {
            showErrorMessage("Bitte gib eine Stadt ein.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            let response = try await weatherService.fetchWeather(for: trimmedCity)
            weatherResponse = response
            lastSearchedCity = response.location.name
            searchText = ""
        } catch let error as WeatherError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Ein unbekannter Fehler ist aufgetreten.")
        }
        
        isLoading = false
    }
    
    /// Lädt das Wetter für den aktuellen Standort
    func fetchWeatherForCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            let location = try await locationManager.getCurrentLocation()
            let response = try await weatherService.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            weatherResponse = response
            lastSearchedCity = response.location.name
        } catch let error as LocationError {
            showErrorMessage(error.localizedDescription)
        } catch let error as WeatherError {
            showErrorMessage(error.localizedDescription)
        } catch {
            showErrorMessage("Ein unbekannter Fehler ist aufgetreten.")
        }
        
        isLoading = false
    }
    
    /// Lädt das Wetter für die letzte gesuchte Stadt oder Standard-Stadt
    func loadInitialWeather() async {
        // Versuche erst den aktuellen Standort
        if locationManager.isLocationAvailable {
            await fetchWeatherForCurrentLocation()
        } else if let lastCity = lastSearchedCity {
            // Ansonsten letzte Stadt
            await fetchWeather(for: lastCity)
        } else {
            // Fallback auf Standard-Stadt
            await fetchWeather(for: Constants.defaultCity)
        }
    }
    
    /// Wechselt zwischen Celsius und Fahrenheit
    func toggleTemperatureUnit() {
        useCelsius.toggle()
    }
    
    /// Fordert die Standortberechtigung an
    func requestLocationPermission() {
        locationManager.requestAuthorization()
    }
    
    /// Führt eine Suche mit dem aktuellen Suchtext durch
    func performSearch() async {
        await fetchWeather(for: searchText)
    }
    
    /// Aktualisiert die Wetterdaten
    func refreshWeather() async {
        if let city = lastSearchedCity {
            await fetchWeather(for: city)
        } else {
            await loadInitialWeather()
        }
    }
    
    // MARK: - Private Methods
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Helper Methods for Forecast
    
    /// Gibt die maximale Temperatur für einen Tag formatiert zurück
    func maxTemperature(for day: DayForecast) -> String {
        let temp = useCelsius ? day.maxtempC : day.maxtempF
        return "\(temp.temperatureString)°"
    }
    
    /// Gibt die minimale Temperatur für einen Tag formatiert zurück
    func minTemperature(for day: DayForecast) -> String {
        let temp = useCelsius ? day.mintempC : day.mintempF
        return "\(temp.temperatureString)°"
    }
    
    /// Gibt die Temperatur für eine Stunde formatiert zurück
    func temperature(for hour: HourForecast) -> String {
        let temp = useCelsius ? hour.tempC : hour.tempF
        return "\(temp.temperatureString)°"
    }
}
