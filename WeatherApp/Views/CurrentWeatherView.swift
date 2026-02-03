import SwiftUI

/// Zeigt die aktuellen Wetterdaten an
struct CurrentWeatherView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Wetter-Icon
            WeatherIcon(condition: viewModel.currentCondition, size: 100)
            
            // Temperatur
            HStack(alignment: .top, spacing: 0) {
                Text(viewModel.currentTemperature)
                    .font(.system(size: 80, weight: .thin))
                    .foregroundColor(.white)
            }
            
            // Wetterbeschreibung
            Text(viewModel.weatherDescription)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
            
            // Gefühlte Temperatur
            Text(viewModel.feelsLikeTemperature)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            // Temperatur-Toggle
            TemperatureToggle()
                .environmentObject(viewModel)
                .padding(.top, 10)
        }
        .padding(.vertical, 30)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        WeatherBackground(condition: .sunny)
            .ignoresSafeArea()
        
        CurrentWeatherView()
            .environmentObject(WeatherViewModel())
    }
}
