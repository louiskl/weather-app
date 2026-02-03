import Foundation
import AVFoundation
import SwiftUI

/// Sound-Typen für verschiedene Wetterbedingungen
enum AmbientSound: String, CaseIterable {
    case rain = "rain"
    case heavyRain = "heavy_rain"
    case thunder = "thunder"
    case wind = "wind"
    case birds = "birds"
    case fireplace = "fireplace"
    case lofi = "lofi"
    case ocean = "ocean"
    case forest = "forest"
    case snow = "snow"
    
    var displayName: String {
        switch self {
        case .rain: return "Leichter Regen"
        case .heavyRain: return "Starkregen"
        case .thunder: return "Gewitter"
        case .wind: return "Wind"
        case .birds: return "Vogelgesang"
        case .fireplace: return "Kaminfeuer"
        case .lofi: return "Lo-Fi Beats"
        case .ocean: return "Meeresrauschen"
        case .forest: return "Waldgeräusche"
        case .snow: return "Winterstille"
        }
    }
    
    var icon: String {
        switch self {
        case .rain, .heavyRain: return "cloud.rain.fill"
        case .thunder: return "cloud.bolt.fill"
        case .wind: return "wind"
        case .birds: return "bird.fill"
        case .fireplace: return "flame.fill"
        case .lofi: return "music.note"
        case .ocean: return "water.waves"
        case .forest: return "leaf.fill"
        case .snow: return "snowflake"
        }
    }
    
    /// Empfohlener Sound für eine Wetterbedingung
    static func recommended(for condition: WeatherCondition) -> AmbientSound {
        switch condition {
        case .sunny, .clear:
            return .birds
        case .rain:
            return .rain
        case .heavyRain:
            return .heavyRain
        case .thunderstorm:
            return .thunder
        case .snow, .sleet:
            return .fireplace
        case .cloudy, .overcast:
            return .lofi
        case .mist, .fog:
            return .forest
        default:
            return .lofi
        }
    }
}

/// Manager für Ambient Sounds
@MainActor
final class AmbientSoundManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isPlaying: Bool = false
    @Published var currentSound: AmbientSound?
    @Published var volume: Float = 0.5
    @Published var autoPlayEnabled: Bool = true
    
    // MARK: - Private Properties
    
    private var audioPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    
    // MARK: - Constants
    
    private enum Keys {
        static let volume = "ambient_volume"
        static let autoPlay = "ambient_autoPlay"
        static let lastSound = "ambient_lastSound"
    }
    
    // MARK: - Initialization
    
    init() {
        loadSettings()
        setupAudioSession()
    }
    
    // MARK: - Public Methods
    
    /// Spielt einen Sound ab
    func play(_ sound: AmbientSound) {
        // Stoppe aktuellen Sound sanft
        if isPlaying {
            fadeOut {
                self.startSound(sound)
            }
        } else {
            startSound(sound)
        }
    }
    
    /// Spielt den empfohlenen Sound für das aktuelle Wetter
    func playRecommended(for condition: WeatherCondition) {
        guard autoPlayEnabled else { return }
        let recommended = AmbientSound.recommended(for: condition)
        play(recommended)
    }
    
    /// Stoppt die Wiedergabe
    func stop() {
        fadeOut {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.isPlaying = false
            self.currentSound = nil
        }
    }
    
    /// Wechselt zwischen Play/Pause
    func toggle() {
        if isPlaying {
            stop()
        } else if let sound = currentSound {
            play(sound)
        } else {
            play(.lofi) // Default Sound
        }
    }
    
    /// Setzt die Lautstärke
    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
        audioPlayer?.volume = volume
        UserDefaults.standard.set(volume, forKey: Keys.volume)
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Setup Error: \(error)")
        }
    }
    
    private func startSound(_ sound: AmbientSound) {
        currentSound = sound
        UserDefaults.standard.set(sound.rawValue, forKey: Keys.lastSound)
        
        // In einer echten App würde hier die Audio-Datei geladen
        // Für die Demo simulieren wir die Wiedergabe
        
        // Beispiel für echte Implementation:
        // guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        // audioPlayer = try? AVAudioPlayer(contentsOf: url)
        // audioPlayer?.numberOfLoops = -1 // Endlos-Loop
        // audioPlayer?.volume = 0
        // audioPlayer?.play()
        
        isPlaying = true
        fadeIn()
    }
    
    private func fadeIn() {
        audioPlayer?.volume = 0
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            Task { @MainActor in
                if let player = self.audioPlayer, player.volume < self.volume {
                    player.volume += 0.02
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    private func fadeOut(completion: @escaping () -> Void) {
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                completion()
                return
            }
            
            Task { @MainActor in
                if let player = self.audioPlayer, player.volume > 0.02 {
                    player.volume -= 0.02
                } else {
                    timer.invalidate()
                    completion()
                }
            }
        }
    }
    
    private func loadSettings() {
        volume = UserDefaults.standard.object(forKey: Keys.volume) as? Float ?? 0.5
        autoPlayEnabled = UserDefaults.standard.object(forKey: Keys.autoPlay) as? Bool ?? true
        
        if let lastSoundRaw = UserDefaults.standard.string(forKey: Keys.lastSound),
           let lastSound = AmbientSound(rawValue: lastSoundRaw) {
            currentSound = lastSound
        }
    }
}

// MARK: - Sound Picker View

struct SoundPickerView: View {
    @EnvironmentObject var soundManager: AmbientSoundManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.indigo.opacity(0.8), .purple.opacity(0.6), .blue.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Lautstärke-Slider
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Slider(value: Binding(
                                    get: { Double(soundManager.volume) },
                                    set: { soundManager.setVolume(Float($0)) }
                                ))
                                .accentColor(.white)
                                
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Toggle("Automatisch abspielen", isOn: $soundManager.autoPlayEnabled)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Sound-Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(AmbientSound.allCases, id: \.self) { sound in
                                SoundCard(
                                    sound: sound,
                                    isSelected: soundManager.currentSound == sound,
                                    isPlaying: soundManager.isPlaying && soundManager.currentSound == sound
                                ) {
                                    if soundManager.currentSound == sound && soundManager.isPlaying {
                                        soundManager.stop()
                                    } else {
                                        soundManager.play(sound)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Sounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct SoundCard: View {
    let sound: AmbientSound
    let isSelected: Bool
    let isPlaying: Bool
    let action: () -> Void
    
    @State private var animatePulse = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    if isPlaying {
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: 70, height: 70)
                            .scaleEffect(animatePulse ? 1.2 : 1.0)
                            .opacity(animatePulse ? 0 : 1)
                    }
                    
                    Image(systemName: sound.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text(sound.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if isPlaying {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            SoundWaveBar(delay: Double(i) * 0.15)
                        }
                    }
                    .frame(height: 15)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
            .cornerRadius(20)
        }
        .onAppear {
            if isPlaying {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                    animatePulse = true
                }
            }
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                    animatePulse = true
                }
            } else {
                animatePulse = false
            }
        }
    }
}

struct SoundWaveBar: View {
    let delay: Double
    @State private var height: CGFloat = 5
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.white)
            .frame(width: 3, height: height)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    height = 15
                }
            }
    }
}
