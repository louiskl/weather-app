import SwiftUI

/// Zeigt ein Wetter-Icon basierend auf der Wetterbedingung an
struct WeatherIcon: View {
    let condition: WeatherCondition
    var size: CGFloat = 50
    var showBackground: Bool = false
    
    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size * 1.5, height: size * 1.5)
            }
            
            Image(systemName: condition.sfSymbolName)
                .font(.system(size: size))
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(condition.iconColor)
                .shadow(color: condition.iconColor.opacity(0.5), radius: 5)
        }
    }
}

// MARK: - Animated Weather Icon

/// Wetter-Icon mit Animation
struct AnimatedWeatherIcon: View {
    let condition: WeatherCondition
    var size: CGFloat = 50
    
    @State private var isAnimating = false
    
    var body: some View {
        WeatherIcon(condition: condition, size: size)
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .opacity(isAnimating ? 1.0 : 0.9)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Mini Weather Icon (für Listen)

struct MiniWeatherIcon: View {
    let code: Int
    var isDay: Bool = true
    var size: CGFloat = 25
    
    private var condition: WeatherCondition {
        WeatherCondition(code: code, isDay: isDay)
    }
    
    var body: some View {
        Image(systemName: condition.sfSymbolName)
            .font(.system(size: size))
            .symbolRenderingMode(.multicolor)
            .foregroundStyle(condition.iconColor)
    }
}

// MARK: - Preview

#Preview("Weather Icons") {
    ScrollView {
        VStack(spacing: 30) {
            ForEach(WeatherCondition.allCases, id: \.self) { condition in
                HStack(spacing: 20) {
                    WeatherIcon(condition: condition, size: 40)
                    
                    Text(condition.description)
                        .font(.body)
                    
                    Spacer()
                    
                    AnimatedWeatherIcon(condition: condition, size: 30)
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.2))
}

#Preview("Large Icon") {
    ZStack {
        WeatherBackground(condition: .sunny)
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            AnimatedWeatherIcon(condition: .sunny, size: 100)
            AnimatedWeatherIcon(condition: .rain, size: 100)
            AnimatedWeatherIcon(condition: .snow, size: 100)
        }
    }
}
