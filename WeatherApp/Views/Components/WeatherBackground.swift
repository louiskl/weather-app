import SwiftUI

/// Dynamischer Hintergrund basierend auf der aktuellen Wetterbedingung
struct WeatherBackground: View {
    let condition: WeatherCondition
    
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: condition.gradientColors,
            startPoint: animateGradient ? .topLeading : .top,
            endPoint: animateGradient ? .bottomTrailing : .bottom
        )
        .overlay {
            // Subtile Animation mit Kreisen
            GeometryReader { geometry in
                ZStack {
                    // Oberer Kreis
                    Circle()
                        .fill(condition.gradientColors.first?.opacity(0.3) ?? Color.clear)
                        .frame(width: geometry.size.width * 0.8)
                        .offset(
                            x: animateGradient ? -50 : 50,
                            y: animateGradient ? -100 : -150
                        )
                        .blur(radius: 60)
                    
                    // Unterer Kreis
                    Circle()
                        .fill(condition.gradientColors.last?.opacity(0.3) ?? Color.clear)
                        .frame(width: geometry.size.width * 0.6)
                        .offset(
                            x: animateGradient ? 80 : 30,
                            y: geometry.size.height * 0.5
                        )
                        .blur(radius: 50)
                }
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Animated Weather Background

/// Erweiterter Hintergrund mit wetterabhängigen Animationen
struct AnimatedWeatherBackground: View {
    let condition: WeatherCondition
    
    var body: some View {
        ZStack {
            // Basis-Gradient
            WeatherBackground(condition: condition)
            
            // Wetterabhängige Overlays
            switch condition {
            case .rain, .heavyRain:
                RainOverlay()
            case .snow:
                SnowOverlay()
            case .thunderstorm:
                ThunderstormOverlay()
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Rain Overlay

struct RainOverlay: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30, id: \.self) { _ in
                RainDrop()
                    .offset(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: animate ? geometry.size.height + 50 : -50
                    )
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false)
            ) {
                animate = true
            }
        }
    }
}

struct RainDrop: View {
    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.3))
            .frame(width: 2, height: 20)
    }
}

// MARK: - Snow Overlay

struct SnowOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { index in
                SnowFlake(delay: Double(index) * 0.2, screenSize: geometry.size)
            }
        }
    }
}

struct SnowFlake: View {
    let delay: Double
    let screenSize: CGSize
    
    @State private var animate = false
    @State private var xPosition: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.6))
            .frame(width: CGFloat.random(in: 4...8))
            .offset(
                x: xPosition,
                y: animate ? screenSize.height + 20 : -20
            )
            .onAppear {
                xPosition = CGFloat.random(in: 0...screenSize.width)
                
                withAnimation(
                    .linear(duration: Double.random(in: 5...10))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

// MARK: - Thunderstorm Overlay

struct ThunderstormOverlay: View {
    @State private var showLightning = false
    
    var body: some View {
        Color.white
            .opacity(showLightning ? 0.3 : 0)
            .ignoresSafeArea()
            .onAppear {
                flashLightning()
            }
    }
    
    private func flashLightning() {
        // Zufällige Blitze
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 3...8)) {
            withAnimation(.easeOut(duration: 0.1)) {
                showLightning = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.1)) {
                    showLightning = false
                }
                
                // Nächster Blitz
                flashLightning()
            }
        }
    }
}

// MARK: - Preview

#Preview("Sunny") {
    WeatherBackground(condition: .sunny)
        .ignoresSafeArea()
}

#Preview("Rainy") {
    AnimatedWeatherBackground(condition: .rain)
        .ignoresSafeArea()
}

#Preview("Snowy") {
    AnimatedWeatherBackground(condition: .snow)
        .ignoresSafeArea()
}

#Preview("Night") {
    WeatherBackground(condition: .clear)
        .ignoresSafeArea()
}
