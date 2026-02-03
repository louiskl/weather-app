import Foundation
import CoreLocation
import Combine

// MARK: - Location Error

/// Fehler bei der Standortermittlung
enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case locationUnknown
    case networkError
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Standortzugriff verweigert. Bitte aktiviere die Standortdienste in den Einstellungen."
        case .authorizationRestricted:
            return "Standortzugriff eingeschränkt. Diese Funktion steht nicht zur Verfügung."
        case .locationUnknown:
            return "Standort konnte nicht ermittelt werden."
        case .networkError:
            return "Netzwerkfehler bei der Standortermittlung."
        case .timeout:
            return "Zeitüberschreitung bei der Standortermittlung."
        }
    }
}

// MARK: - Location Manager

/// Manager für Standortdienste mit CoreLocation
final class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Aktueller Standort
    @Published var location: CLLocation?
    
    /// Aktueller Autorisierungsstatus
    @Published var authorizationStatus: CLAuthorizationStatus
    
    /// Fehler bei der Standortermittlung
    @Published var locationError: LocationError?
    
    /// Zeigt an, ob gerade der Standort ermittelt wird
    @Published var isLocating = false
    
    // MARK: - Private Properties
    
    private let locationManager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    // MARK: - Initialization
    
    override init() {
        self.locationManager = CLLocationManager()
        self.authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // Update nur bei 1km Änderung
    }
    
    // MARK: - Public Methods
    
    /// Fordert die Standortberechtigung an
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Ermittelt den aktuellen Standort einmalig
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        
        isLocating = true
        locationError = nil
        locationManager.requestLocation()
    }
    
    /// Ermittelt den aktuellen Standort asynchron
    /// - Returns: CLLocation des aktuellen Standorts
    func getCurrentLocation() async throws -> CLLocation {
        // Prüfe Berechtigung
        switch authorizationStatus {
        case .notDetermined:
            requestAuthorization()
            // Warte kurz auf Berechtigungsänderung
            try await Task.sleep(nanoseconds: 500_000_000)
            return try await getCurrentLocation()
            
        case .denied:
            throw LocationError.authorizationDenied
            
        case .restricted:
            throw LocationError.authorizationRestricted
            
        case .authorizedWhenInUse, .authorizedAlways:
            break
            
        @unknown default:
            throw LocationError.authorizationDenied
        }
        
        // Wenn bereits ein Standort vorhanden ist und er aktuell genug ist
        if let location = location,
           Date().timeIntervalSince(location.timestamp) < 300 { // 5 Minuten
            return location
        }
        
        // Neuen Standort anfordern
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            
            DispatchQueue.main.async {
                self.isLocating = true
                self.locationError = nil
                self.locationManager.requestLocation()
            }
            
            // Timeout nach 15 Sekunden
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
                guard let self = self, self.locationContinuation != nil else { return }
                self.locationContinuation?.resume(throwing: LocationError.timeout)
                self.locationContinuation = nil
                self.isLocating = false
            }
        }
    }
    
    /// Prüft, ob Standortdienste verfügbar und autorisiert sind
    var isLocationAvailable: Bool {
        CLLocationManager.locationServicesEnabled() &&
        (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways)
    }
    
    /// Prüft, ob die Berechtigung noch nicht angefragt wurde
    var canRequestAuthorization: Bool {
        authorizationStatus == .notDetermined
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = newLocation
            self.isLocating = false
            self.locationError = nil
            
            // Continuation erfüllen falls vorhanden
            self.locationContinuation?.resume(returning: newLocation)
            self.locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLocating = false
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.locationError = .authorizationDenied
                    self.locationContinuation?.resume(throwing: LocationError.authorizationDenied)
                case .network:
                    self.locationError = .networkError
                    self.locationContinuation?.resume(throwing: LocationError.networkError)
                default:
                    self.locationError = .locationUnknown
                    self.locationContinuation?.resume(throwing: LocationError.locationUnknown)
                }
            } else {
                self.locationError = .locationUnknown
                self.locationContinuation?.resume(throwing: LocationError.locationUnknown)
            }
            
            self.locationContinuation = nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            // Wenn Berechtigung erteilt wurde, Standort anfordern
            if self.authorizationStatus == .authorizedWhenInUse ||
               self.authorizationStatus == .authorizedAlways {
                self.requestLocation()
            }
        }
    }
}
