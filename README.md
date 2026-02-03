# Wetter-App für iOS

Eine moderne, elegante Wetter-App für iOS, entwickelt mit SwiftUI.

## Features

- **Aktuelles Wetter**: Temperatur, Wetterbedingungen, Luftfeuchtigkeit, Wind und mehr
- **5-Tage-Vorhersage**: Tägliche Wettervorhersage mit Min/Max-Temperaturen
- **Stündliche Vorhersage**: Detaillierte stündliche Wetterprognose
- **Standorterkennung**: Automatische Wetterdaten für den aktuellen Standort (CoreLocation)
- **Stadtsuche**: Suche nach beliebigen Städten weltweit
- **Dynamische Hintergründe**: Farbverläufe, die sich dem aktuellen Wetter anpassen
- **Celsius/Fahrenheit Toggle**: Einfacher Wechsel zwischen Temperatureinheiten
- **Pull-to-Refresh**: Aktualisiere die Wetterdaten durch Herunterziehen

## Technologien

- **SwiftUI**: Moderne, deklarative UI-Entwicklung
- **MVVM-Architektur**: Klare Trennung von Daten, Logik und Darstellung
- **Async/Await**: Moderne asynchrone Programmierung
- **CoreLocation**: Standortdienste für GPS-basierte Wetterabfragen
- **Codable**: Einfache JSON-Verarbeitung

## Voraussetzungen

- Xcode 15.0 oder neuer
- iOS 17.0 oder neuer
- WeatherAPI.com API-Schlüssel (kostenlos)

## Installation

### 1. API-Schlüssel einrichten

1. Registriere dich kostenlos bei [WeatherAPI.com](https://www.weatherapi.com/)
2. Kopiere deinen API-Schlüssel
3. Öffne `WeatherApp/Utilities/Constants.swift`
4. Ersetze `DEIN_API_KEY_HIER` mit deinem API-Schlüssel:

```swift
static let apiKey = "dein_echter_api_key"
```

### 2. Projekt in Xcode öffnen

1. Öffne Xcode
2. Wähle "Create a new Xcode project"
3. Wähle "App" unter iOS
4. Konfiguriere das Projekt:
   - Product Name: `WeatherApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
5. Kopiere alle Dateien aus dem `WeatherApp/` Ordner in das neue Projekt

### 3. Ordnerstruktur einrichten

Erstelle in Xcode folgende Gruppen und füge die entsprechenden Dateien hinzu:

```
WeatherApp/
├── WeatherApp.swift
├── Models/
│   ├── WeatherResponse.swift
│   └── WeatherCondition.swift
├── ViewModels/
│   └── WeatherViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── CurrentWeatherView.swift
│   ├── ForecastView.swift
│   ├── SearchBar.swift
│   ├── WeatherDetailsView.swift
│   └── Components/
│       ├── WeatherBackground.swift
│       ├── WeatherIcon.swift
│       ├── TemperatureToggle.swift
│       └── LoadingView.swift
├── Services/
│   ├── WeatherService.swift
│   └── LocationManager.swift
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift
```

### 4. Info.plist konfigurieren

Die `Info.plist` enthält bereits die notwendigen Berechtigungsanfragen für Standortdienste. Falls du ein neues Projekt erstellst, füge diese Einträge hinzu:

- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription` (optional)

## Projektstruktur

### Models
- `WeatherResponse.swift`: Codable-Strukturen für die API-Antwort
- `WeatherCondition.swift`: Enum für Wetterbedingungen mit Icons und Farben

### ViewModels
- `WeatherViewModel.swift`: Zentrale Geschäftslogik und State-Management

### Views
- `ContentView.swift`: Hauptansicht mit Navigation
- `CurrentWeatherView.swift`: Aktuelle Wetterdaten
- `ForecastView.swift`: 5-Tage und stündliche Vorhersage
- `WeatherDetailsView.swift`: Detaillierte Wetterinformationen
- `SearchBar.swift`: Suchkomponenten

### Components
- `WeatherBackground.swift`: Dynamische Hintergrundanimationen
- `WeatherIcon.swift`: SF Symbols für Wetterbedingungen
- `TemperatureToggle.swift`: Celsius/Fahrenheit Umschalter
- `LoadingView.swift`: Ladeanimationen

### Services
- `WeatherService.swift`: API-Kommunikation mit WeatherAPI.com
- `LocationManager.swift`: CoreLocation-Integration

## API-Referenz

Die App verwendet [WeatherAPI.com](https://www.weatherapi.com/) mit folgendem Endpoint:

```
GET https://api.weatherapi.com/v1/forecast.json
    ?key={API_KEY}
    &q={city}
    &days=5
    &lang=de
```

## Anpassungen

### Farben ändern

Bearbeite `WeatherCondition.swift` und ändere die `gradientColors` für verschiedene Wetterbedingungen.

### Standard-Stadt ändern

Bearbeite `Constants.swift`:

```swift
static let defaultCity = "München"
```

### Vorhersage-Tage ändern

Bearbeite `Constants.swift`:

```swift
static let forecastDays = 7  // Maximal 10 Tage (abhängig vom API-Plan)
```

## Screenshots

Die App zeigt:
- Große Temperaturanzeige mit Wetter-Icon
- Gefühlte Temperatur
- Stündliche Vorhersage als horizontale ScrollView
- Detailkarten (Luftfeuchtigkeit, Wind, UV-Index, etc.)
- 5-Tage-Vorhersage mit Hoch/Tief-Temperaturen

## Lizenz

Dieses Projekt ist für Bildungszwecke erstellt worden.

## Mitwirken

Verbesserungsvorschläge und Pull Requests sind willkommen!
