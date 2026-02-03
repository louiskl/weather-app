import SwiftUI

/// Zeigt die 5-Tage-Wettervorhersage an
struct ForecastView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            Label("5-Tage-Vorhersage", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            // Vorhersage-Tage
            VStack(spacing: 0) {
                ForEach(viewModel.forecast) { forecastDay in
                    ForecastDayRow(
                        forecastDay: forecastDay,
                        maxTemp: viewModel.maxTemperature(for: forecastDay.day),
                        minTemp: viewModel.minTemperature(for: forecastDay.day)
                    )
                    
                    if forecastDay.id != viewModel.forecast.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.2))
                    }
                }
            }
            .padding()
            .glassBackground()
        }
    }
}

// MARK: - Forecast Day Row

struct ForecastDayRow: View {
    let forecastDay: ForecastDay
    let maxTemp: String
    let minTemp: String
    
    private var weekday: String {
        forecastDay.dateObject?.weekdayName ?? "Unbekannt"
    }
    
    private var condition: WeatherCondition {
        WeatherCondition(code: forecastDay.day.condition.code)
    }
    
    var body: some View {
        HStack {
            // Wochentag
            Text(weekday)
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            // Regenwahrscheinlichkeit
            if forecastDay.day.dailyChanceOfRain > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.caption)
                        .foregroundColor(.cyan)
                    Text("\(forecastDay.day.dailyChanceOfRain)%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(width: 50)
            } else {
                Spacer()
                    .frame(width: 50)
            }
            
            Spacer()
            
            // Wetter-Icon
            WeatherIcon(condition: condition, size: 30)
                .frame(width: 40)
            
            Spacer()
            
            // Temperaturen
            HStack(spacing: 15) {
                Text(maxTemp)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 45, alignment: .trailing)
                
                Text(minTemp)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 45, alignment: .trailing)
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Hourly Forecast View

struct HourlyForecastView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            Label("Stündlich", systemImage: "clock")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            // Horizontale ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.hourlyForecast.prefix(12)) { hour in
                        HourlyForecastItem(
                            hour: hour,
                            temperature: viewModel.temperature(for: hour)
                        )
                    }
                }
                .padding(.horizontal, 5)
            }
            .padding()
            .glassBackground()
        }
    }
}

// MARK: - Hourly Forecast Item

struct HourlyForecastItem: View {
    let hour: HourForecast
    let temperature: String
    
    private var condition: WeatherCondition {
        WeatherCondition(code: hour.condition.code, isDay: hour.isDay == 1)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Uhrzeit
            Text(hour.hourString)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            // Icon
            WeatherIcon(condition: condition, size: 25)
            
            // Temperatur
            Text(temperature)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // Regenwahrscheinlichkeit
            if hour.chanceOfRain > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.cyan)
                    Text("\(hour.chanceOfRain)%")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(width: 60)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        WeatherBackground(condition: .partlyCloudy)
            .ignoresSafeArea()
        
        ScrollView {
            VStack {
                HourlyForecastView()
                ForecastView()
            }
            .padding()
        }
        .environmentObject(WeatherViewModel())
    }
}
