import Foundation

// MARK: - Weather Error

/// Fehler, die beim Abrufen von Wetterdaten auftreten können
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidCity
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
    case noData
    case invalidAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige URL"
        case .invalidCity:
            return "Stadt nicht gefunden. Bitte überprüfe die Eingabe."
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .decodingError:
            return "Fehler beim Verarbeiten der Wetterdaten"
        case .apiError(let message):
            return message
        case .noData:
            return "Keine Daten erhalten"
        case .invalidAPIKey:
            return "Ungültiger API-Schlüssel. Bitte überprüfe deine Konfiguration."
        }
    }
}

// MARK: - Weather Service Protocol

/// Protokoll für Weather Service (nützlich für Testing)
protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> WeatherResponse
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse
}

// MARK: - Weather Service

/// Service für die Kommunikation mit der WeatherAPI.com
final class WeatherService: WeatherServiceProtocol {
    
    // MARK: - Singleton
    
    static let shared = WeatherService()
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Public Methods
    
    /// Ruft Wetterdaten für eine Stadt ab
    /// - Parameter city: Name der Stadt
    /// - Returns: WeatherResponse mit aktuellen Daten und Vorhersage
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        let query = city.urlEncoded
        return try await fetchWeather(query: query)
    }
    
    /// Ruft Wetterdaten für Koordinaten ab
    /// - Parameters:
    ///   - latitude: Breitengrad
    ///   - longitude: Längengrad
    /// - Returns: WeatherResponse mit aktuellen Daten und Vorhersage
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let query = "\(latitude),\(longitude)"
        return try await fetchWeather(query: query)
    }
    
    // MARK: - Private Methods
    
    /// Führt die eigentliche API-Anfrage durch
    private func fetchWeather(query: String) async throws -> WeatherResponse {
        // URL zusammenbauen
        let urlString = "\(Constants.baseURL)\(Constants.forecastEndpoint)?key=\(Constants.apiKey)&q=\(query)&days=\(Constants.forecastDays)&lang=\(Constants.apiLanguage)&aqi=no"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        // API-Anfrage durchführen
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherError.networkError(error)
        }
        
        // HTTP-Status prüfen
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.noData
        }
        
        // Fehlerbehandlung basierend auf Status-Code
        switch httpResponse.statusCode {
        case 200:
            // Erfolg - Daten dekodieren
            break
        case 400:
            // API-Fehler (z.B. Stadt nicht gefunden)
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                if errorResponse.error.code == 1006 {
                    throw WeatherError.invalidCity
                }
                throw WeatherError.apiError(errorResponse.error.message)
            }
            throw WeatherError.invalidCity
        case 401, 403:
            throw WeatherError.invalidAPIKey
        default:
            throw WeatherError.apiError("Server-Fehler: \(httpResponse.statusCode)")
        }
        
        // JSON dekodieren
        do {
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            return weatherResponse
        } catch {
            print("Decoding error: \(error)")
            throw WeatherError.decodingError(error)
        }
    }
}
