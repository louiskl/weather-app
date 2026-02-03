import UIKit
import CoreHaptics

/// Manager für haptisches Feedback basierend auf Wetter-Events
final class HapticEngine {
    
    // MARK: - Singleton
    
    static let shared = HapticEngine()
    
    // MARK: - Properties
    
    private var engine: CHHapticEngine?
    private var isEnabled: Bool = true
    
    // MARK: - Initialization
    
    private init() {
        prepareHaptics()
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    /// Aktiviert/Deaktiviert Haptics
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "haptics_enabled")
    }
    
    /// Standard Impact Feedback
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// Notification Feedback
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// Selection Feedback
    func selection() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Weather-spezifische Haptics
    
    /// Regen-Haptic: Sanftes, kontinuierliches Tippen
    func rainEffect() {
        guard isEnabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            // Fallback für Geräte ohne Core Haptics
            impact(.light)
            return
        }
        
        do {
            let pattern = try rainPattern()
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Haptic rain effect failed: \(error)")
        }
    }
    
    /// Gewitter-Haptic: Starker Impuls
    func thunderEffect() {
        guard isEnabled else { return }
        
        // Starker initialer Impact
        impact(.heavy)
        
        // Nachfolgende leichtere Impacts für "Nachhall"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impact(.light)
        }
    }
    
    /// Wind-Haptic: Rhythmisches, wellenförmiges Feedback
    func windEffect() {
        guard isEnabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            impact(.light)
            return
        }
        
        do {
            let pattern = try windPattern()
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Haptic wind effect failed: \(error)")
        }
    }
    
    /// Schnee-Haptic: Sehr sanfte, vereinzelte Impulse
    func snowEffect() {
        guard isEnabled else { return }
        impact(.soft)
    }
    
    /// Sonnig-Haptic: Warmes, sanftes Pulsieren
    func sunnyEffect() {
        guard isEnabled else { return }
        impact(.light)
    }
    
    /// Achievement-Unlock Haptic
    func achievementUnlocked() {
        guard isEnabled else { return }
        notification(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impact(.medium)
        }
    }
    
    /// Streak-Milestone Haptic
    func streakMilestone() {
        guard isEnabled else { return }
        
        // Aufsteigendes Feedback
        impact(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impact(.heavy)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.notification(.success)
        }
    }
    
    /// Button-Tap Haptic
    func buttonTap() {
        guard isEnabled else { return }
        impact(.light)
    }
    
    /// Error Haptic
    func error() {
        guard isEnabled else { return }
        notification(.error)
    }
    
    /// Wetter-Wechsel Haptic
    func weatherChanged(to condition: WeatherCondition) {
        guard isEnabled else { return }
        
        switch condition {
        case .sunny, .clear:
            sunnyEffect()
        case .rain:
            rainEffect()
        case .heavyRain:
            impact(.medium)
        case .thunderstorm:
            thunderEffect()
        case .snow, .sleet:
            snowEffect()
        case .cloudy, .overcast:
            impact(.soft)
        default:
            impact(.light)
        }
    }
    
    // MARK: - Private Methods
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Engine automatisch neu starten wenn sie stoppt
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    private func loadSettings() {
        isEnabled = UserDefaults.standard.object(forKey: "haptics_enabled") as? Bool ?? true
    }
    
    // MARK: - Haptic Patterns
    
    private func rainPattern() throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        
        // Mehrere kleine Taps für Regentropfen-Effekt
        for i in 0..<10 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float.random(in: 0.2...0.4))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float.random(in: 0.1...0.3))
            
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: TimeInterval(i) * 0.1 + Double.random(in: 0...0.05)
            )
            events.append(event)
        }
        
        return try CHHapticPattern(events: events, parameters: [])
    }
    
    private func windPattern() throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        
        // Wellenförmiges Muster
        let duration: TimeInterval = 1.0
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: duration
        )
        events.append(event)
        
        // Intensitäts-Kurve für "Wind"-Effekt
        let curve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0, value: 0.2),
                .init(relativeTime: 0.25, value: 0.6),
                .init(relativeTime: 0.5, value: 0.3),
                .init(relativeTime: 0.75, value: 0.7),
                .init(relativeTime: 1.0, value: 0.2)
            ],
            relativeTime: 0
        )
        
        return try CHHapticPattern(events: events, parameterCurves: [curve])
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Fügt haptisches Feedback beim Tap hinzu
    func hapticTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                HapticEngine.shared.impact(style)
            }
        )
    }
    
    /// Fügt haptisches Feedback bei Änderung hinzu
    func hapticOnChange<V: Equatable>(of value: V, perform action: @escaping () -> Void = {}) -> some View {
        self.onChange(of: value) { _, _ in
            HapticEngine.shared.selection()
            action()
        }
    }
}
