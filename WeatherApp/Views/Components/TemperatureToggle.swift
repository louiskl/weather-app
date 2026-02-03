import SwiftUI

/// Toggle zwischen Celsius und Fahrenheit
struct TemperatureToggle: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            // Celsius Button
            TemperatureUnitButton(
                unit: "°C",
                isSelected: viewModel.useCelsius
            ) {
                if !viewModel.useCelsius {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.useCelsius = true
                    }
                }
            }
            
            // Fahrenheit Button
            TemperatureUnitButton(
                unit: "°F",
                isSelected: !viewModel.useCelsius
            ) {
                if viewModel.useCelsius {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.useCelsius = false
                    }
                }
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

// MARK: - Temperature Unit Button

struct TemperatureUnitButton: View {
    let unit: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(unit)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.white.opacity(0.2) : Color.clear
                )
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Temperature Toggle

/// Kompaktere Version des Toggle für engere Platzverhältnisse
struct CompactTemperatureToggle: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleTemperatureUnit()
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.useCelsius ? "°C" : "°F")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 10))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        WeatherBackground(condition: .sunny)
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            TemperatureToggle()
            
            CompactTemperatureToggle()
        }
        .environmentObject(WeatherViewModel())
    }
}
