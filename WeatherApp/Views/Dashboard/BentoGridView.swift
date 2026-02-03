import SwiftUI

/// Modernes Bento-Grid Dashboard Layout
struct BentoGridView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var achievementSystem: AchievementSystem
    @EnvironmentObject var soundManager: AmbientSoundManager
    
    @State private var showOutfitDetail = false
    @State private var showAchievements = false
    @State private var showPredictionGame = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                // Obere Reihe: Temperatur + Outfit
                HStack(spacing: 12) {
                    // Große Temperatur-Karte
                    TemperatureBentoCard()
                        .environmentObject(viewModel)
                    
                    // Outfit-Tipp Karte
                    OutfitBentoCard(showDetail: $showOutfitDetail)
                        .environmentObject(viewModel)
                }
                .frame(height: 200)
                
                // Mittlere Reihe: Streak, Badge, Sound
                HStack(spacing: 12) {
                    StreakBentoCard()
                        .environmentObject(streakManager)
                    
                    BadgeBentoCard(showAchievements: $showAchievements)
                        .environmentObject(achievementSystem)
                    
                    SoundBentoCard()
                        .environmentObject(soundManager)
                }
                .frame(height: 100)
                
                // Vorhersage-Challenge Karte
                PredictionChallengeBentoCard(showGame: $showPredictionGame)
                    .environmentObject(viewModel)
                    .frame(height: 80)
                
                // Stündliche Vorhersage
                if !viewModel.hourlyForecast.isEmpty {
                    HourlyForecastBentoCard()
                        .environmentObject(viewModel)
                        .frame(height: 140)
                }
                
                // 5-Tage Vorhersage
                if !viewModel.forecast.isEmpty {
                    ForecastBentoCard()
                        .environmentObject(viewModel)
                }
                
                // Details Grid
                DetailsBentoGrid()
                    .environmentObject(viewModel)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showOutfitDetail) {
            OutfitDetailView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
                .environmentObject(achievementSystem)
        }
        .sheet(isPresented: $showPredictionGame) {
            PredictionGameView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Temperatur Bento Card

struct TemperatureBentoCard: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 8) {
                // Wetter-Icon
                WeatherIcon(condition: viewModel.currentCondition, size: 40)
                
                Spacer()
                
                // Temperatur
                Text(viewModel.currentTemperature)
                    .font(.system(size: 56, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                
                // Beschreibung
                Text(viewModel.weatherDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                // Gefühlt
                Text(viewModel.feelsLikeTemperature)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Outfit Bento Card

struct OutfitBentoCard: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Binding var showDetail: Bool
    
    var recommendation: OutfitRecommendation {
        OutfitRecommender.shared.getRecommendation(for: viewModel.weatherResponse)
    }
    
    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "tshirt.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Outfit")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Outfit Icon
                Text(recommendation.emoji)
                    .font(.system(size: 36))
                
                Text(recommendation.shortTip)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            showDetail = true
        }
    }
}

// MARK: - Streak Bento Card

struct StreakBentoCard: View {
    @EnvironmentObject var streakManager: StreakManager
    
    var body: some View {
        BentoCard(style: .accent) {
            VStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("\(streakManager.currentStreak)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Tage")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Badge Bento Card

struct BadgeBentoCard: View {
    @EnvironmentObject var achievementSystem: AchievementSystem
    @Binding var showAchievements: Bool
    
    var body: some View {
        BentoCard {
            VStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("\(achievementSystem.unlockedCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Badges")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onTapGesture {
            showAchievements = true
        }
    }
}

// MARK: - Sound Bento Card

struct SoundBentoCard: View {
    @EnvironmentObject var soundManager: AmbientSoundManager
    
    var body: some View {
        BentoCard {
            VStack(spacing: 4) {
                Image(systemName: soundManager.isPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.title2)
                    .foregroundColor(soundManager.isPlaying ? .cyan : .white.opacity(0.5))
                
                Text(soundManager.isPlaying ? "An" : "Aus")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Sound")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onTapGesture {
            soundManager.toggle()
        }
    }
}

// MARK: - Prediction Challenge Card

struct PredictionChallengeBentoCard: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Binding var showGame: Bool
    
    var body: some View {
        BentoCard(style: .gradient) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wetter-Challenge")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Rate das Wetter von morgen!")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "dice.fill")
                    .font(.title)
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .onTapGesture {
            showGame = true
        }
    }
}

// MARK: - Hourly Forecast Bento Card

struct HourlyForecastBentoCard: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.white.opacity(0.7))
                    Text("Stündlich")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.hourlyForecast.prefix(12)) { hour in
                            VStack(spacing: 6) {
                                Text(hour.hourString)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                MiniWeatherIcon(code: hour.condition.code, isDay: hour.isDay == 1, size: 20)
                                
                                Text(viewModel.temperature(for: hour))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Forecast Bento Card

struct ForecastBentoCard: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.white.opacity(0.7))
                    Text("5-Tage")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 8) {
                    ForEach(viewModel.forecast) { day in
                        HStack {
                            Text(day.dateObject?.shortWeekdayName ?? "")
                                .font(.subheadline)
                                .frame(width: 30, alignment: .leading)
                                .foregroundColor(.white)
                            
                            MiniWeatherIcon(code: day.day.condition.code, size: 22)
                                .frame(width: 30)
                            
                            Spacer()
                            
                            // Rain chance
                            if day.day.dailyChanceOfRain > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.cyan)
                                    Text("\(day.day.dailyChanceOfRain)%")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .frame(width: 45)
                            } else {
                                Spacer().frame(width: 45)
                            }
                            
                            Text(viewModel.maxTemperature(for: day.day))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(width: 35, alignment: .trailing)
                            
                            Text(viewModel.minTemperature(for: day.day))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                                .frame(width: 35, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Details Bento Grid

struct DetailsBentoGrid: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            DetailMiniCard(icon: "humidity", title: "Feuchtigkeit", value: viewModel.humidity)
            DetailMiniCard(icon: "wind", title: "Wind", value: viewModel.windSpeed)
            DetailMiniCard(icon: "sun.max", title: "UV-Index", value: viewModel.uvIndex)
        }
    }
}

struct DetailMiniCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        BentoCard {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Bento Card Container

enum BentoCardStyle {
    case standard
    case accent
    case gradient
}

struct BentoCard<Content: View>: View {
    let style: BentoCardStyle
    let content: Content
    
    init(style: BentoCardStyle = .standard, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundView)
            .cornerRadius(20)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .standard:
            Color.white.opacity(0.1)
                .background(.ultraThinMaterial)
        case .accent:
            LinearGradient(
                colors: [.orange.opacity(0.3), .red.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(.ultraThinMaterial)
        case .gradient:
            LinearGradient(
                colors: [.purple.opacity(0.4), .blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        WeatherBackground(condition: .sunny)
            .ignoresSafeArea()
        
        BentoGridView()
            .environmentObject(WeatherViewModel())
            .environmentObject(StreakManager())
            .environmentObject(AchievementSystem())
            .environmentObject(AmbientSoundManager())
    }
}
