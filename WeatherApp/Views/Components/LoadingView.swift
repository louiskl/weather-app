import SwiftUI

/// Ladeansicht während Daten abgerufen werden
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Animiertes Wetter-Icon
            ZStack {
                // Hintergrund-Kreis
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                // Animierter Kreis
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                
                // Wetter-Icon in der Mitte
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 30))
                    .symbolRenderingMode(.multicolor)
            }
            
            Text("Wetterdaten werden geladen...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Inline Loading Indicator

/// Kompakter Ladeindikator für inline-Nutzung
struct InlineLoadingIndicator: View {
    var message: String = "Laden..."
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 16, height: 16)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            
            Text(message)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            withAnimation(
                .linear(duration: 0.8)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Skeleton Loading View

/// Skeleton-Platzhalter für Ladeanimation
struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Temperatur Skeleton
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.2))
                .frame(width: 150, height: 80)
            
            // Beschreibung Skeleton
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.15))
                .frame(width: 100, height: 20)
            
            // Details Skeleton
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 60)
                }
            }
        }
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Loading View") {
    ZStack {
        WeatherBackground(condition: .cloudy)
            .ignoresSafeArea()
        
        LoadingView()
    }
}

#Preview("Inline Loading") {
    ZStack {
        WeatherBackground(condition: .rain)
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            InlineLoadingIndicator()
            InlineLoadingIndicator(message: "Standort wird ermittelt...")
        }
    }
}

#Preview("Skeleton Loading") {
    ZStack {
        WeatherBackground(condition: .partlyCloudy)
            .ignoresSafeArea()
        
        SkeletonLoadingView()
    }
}
