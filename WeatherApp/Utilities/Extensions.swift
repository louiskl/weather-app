import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    /// Formatiert das Datum als Wochentag (z.B. "Montag")
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    /// Formatiert das Datum kurz (z.B. "Mo")
    var shortWeekdayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EE"
        return formatter.string(from: self)
    }
    
    /// Formatiert das Datum als "dd.MM" (z.B. "03.02")
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: self)
    }
}

// MARK: - Double Extensions

extension Double {
    /// Rundet auf eine Dezimalstelle und gibt als String zurück
    var temperatureString: String {
        return String(format: "%.0f", self)
    }
}

// MARK: - String Extensions

extension String {
    /// Entfernt führende und nachfolgende Leerzeichen
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// URL-kodiert den String für API-Anfragen
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

// MARK: - View Extensions

extension View {
    /// Fügt einen Schatten mit Standard-Wetter-App-Styling hinzu
    func weatherCardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    /// Wendet einen glassmorphism-Effekt an
    func glassBackground() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}

// MARK: - Color Extensions

extension Color {
    /// Primäre Akzentfarbe der App
    static let weatherPrimary = Color.blue
    
    /// Sekundäre Farbe für Texte
    static let weatherSecondary = Color.white.opacity(0.7)
}
