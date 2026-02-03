import SwiftUI

/// Zeigt detaillierte Wetterinformationen in einem Grid an
struct WeatherDetailsView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            Label("Details", systemImage: "info.circle")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            // Detail-Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                // Luftfeuchtigkeit
                WeatherDetailCard(
                    icon: "humidity",
                    title: "Luftfeuchtigkeit",
                    value: viewModel.humidity
                )
                
                // Wind
                WeatherDetailCard(
                    icon: "wind",
                    title: "Wind",
                    value: viewModel.windSpeed
                )
                
                // UV-Index
                WeatherDetailCard(
                    icon: "sun.max",
                    title: "UV-Index",
                    value: viewModel.uvIndex
                )
                
                // Sichtweite
                if let weather = viewModel.weatherResponse?.current {
                    WeatherDetailCard(
                        icon: "eye",
                        title: "Sichtweite",
                        value: "\(Int(weather.visKm)) km"
                    )
                }
                
                // Luftdruck
                if let weather = viewModel.weatherResponse?.current {
                    WeatherDetailCard(
                        icon: "gauge",
                        title: "Luftdruck",
                        value: "\(Int(weather.pressureMb)) hPa"
                    )
                }
                
                // Windrichtung
                if let weather = viewModel.weatherResponse?.current {
                    WeatherDetailCard(
                        icon: "location.north",
                        title: "Windrichtung",
                        value: weather.windDir
                    )
                }
            }
        }
    }
}

// MARK: - Weather Detail Card

struct WeatherDetailCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon und Titel
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Wert
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassBackground()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        WeatherBackground(condition: .sunny)
            .ignoresSafeArea()
        
        WeatherDetailsView()
            .environmentObject(WeatherViewModel())
            .padding()
    }
}
