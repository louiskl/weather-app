import SwiftUI
import UIKit

// MARK: - Share Card Templates

enum ShareCardTemplate: String, CaseIterable {
    case minimal = "Minimal"
    case gradient = "Gradient"
    case neon = "Neon"
    case polaroid = "Polaroid"
    case magazine = "Magazine"
    
    var backgroundColor: [Color] {
        switch self {
        case .minimal:
            return [.white]
        case .gradient:
            return [.blue, .purple, .pink]
        case .neon:
            return [.black]
        case .polaroid:
            return [.white]
        case .magazine:
            return [Color(white: 0.95)]
        }
    }
}

// MARK: - Share Card View

struct ShareCardView: View {
    let weather: WeatherResponse
    let template: ShareCardTemplate
    let useCelsius: Bool
    
    private var temperature: String {
        let temp = useCelsius ? weather.current.tempC : weather.current.tempF
        return "\(Int(temp))°"
    }
    
    private var condition: WeatherCondition {
        WeatherCondition(code: weather.current.condition.code, isDay: weather.current.isDay == 1)
    }
    
    var body: some View {
        Group {
            switch template {
            case .minimal:
                minimalCard
            case .gradient:
                gradientCard
            case .neon:
                neonCard
            case .polaroid:
                polaroidCard
            case .magazine:
                magazineCard
            }
        }
        .frame(width: 300, height: 400)
    }
    
    // MARK: - Minimal Template
    
    private var minimalCard: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(temperature)
                .font(.system(size: 80, weight: .ultraLight))
                .foregroundColor(.black)
            
            Text(weather.location.name)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Text(weather.current.condition.text)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            // App Branding
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .foregroundColor(.blue)
                Text("WeatherApp")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
    
    // MARK: - Gradient Template
    
    private var gradientCard: some View {
        ZStack {
            LinearGradient(
                colors: condition.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 15) {
                Text(weather.location.name)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                WeatherIcon(condition: condition, size: 60)
                
                Text(temperature)
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.white)
                
                Text(weather.current.condition.text)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Stats
                HStack(spacing: 30) {
                    VStack {
                        Image(systemName: "humidity.fill")
                        Text("\(weather.current.humidity)%")
                            .fontWeight(.medium)
                    }
                    
                    VStack {
                        Image(systemName: "wind")
                        Text("\(Int(weather.current.windKph)) km/h")
                            .fontWeight(.medium)
                    }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                
                // Branding
                Text("via WeatherApp")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 15)
            }
            .padding(.top, 30)
        }
    }
    
    // MARK: - Neon Template
    
    private var neonCard: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 20) {
                Text(weather.location.name.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(4)
                    .foregroundColor(.cyan)
                
                Spacer()
                
                Text(temperature)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .cyan, radius: 20)
                    .shadow(color: .purple, radius: 40)
                
                Text(weather.current.condition.text)
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundColor(.pink)
                    .shadow(color: .pink, radius: 10)
                
                Spacer()
                
                // Neon line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .shadow(color: .cyan, radius: 5)
                    .padding(.horizontal, 40)
                
                Text("WEATHER APP")
                    .font(.caption2)
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 15)
            }
            .padding(.top, 30)
        }
    }
    
    // MARK: - Polaroid Template
    
    private var polaroidCard: some View {
        VStack(spacing: 0) {
            // Foto-Bereich
            ZStack {
                LinearGradient(
                    colors: condition.gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack {
                    WeatherIcon(condition: condition, size: 80)
                    
                    Text(temperature)
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 280)
            
            // Polaroid Beschriftung
            VStack(spacing: 5) {
                Text(weather.location.name)
                    .font(.system(.title3, design: .serif))
                    .italic()
                
                Text(weather.current.condition.text)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        .padding(15)
        .background(Color(white: 0.95))
    }
    
    // MARK: - Magazine Template
    
    private var magazineCard: some View {
        ZStack {
            Color(white: 0.95)
            
            VStack(alignment: .leading, spacing: 15) {
                // Header
                HStack {
                    Text("WEATHER")
                        .font(.caption)
                        .fontWeight(.black)
                        .tracking(2)
                    
                    Spacer()
                    
                    Text(Date(), style: .date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // Hauptinhalt
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(weather.location.name)
                            .font(.system(.largeTitle, design: .serif))
                            .fontWeight(.bold)
                        
                        Text(weather.location.country)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(temperature)
                        .font(.system(size: 50, weight: .ultraLight))
                }
                
                // Condition
                Text(weather.current.condition.text)
                    .font(.system(.title, design: .serif))
                    .italic()
                
                Spacer()
                
                // Stats Grid
                HStack {
                    StatBox(label: "HUMIDITY", value: "\(weather.current.humidity)%")
                    StatBox(label: "WIND", value: "\(Int(weather.current.windKph))")
                    StatBox(label: "UV", value: String(format: "%.0f", weather.current.uv))
                }
                
                Divider()
                
                Text("Powered by WeatherApp")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(25)
        }
    }
}

struct StatBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title3)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Share Card Generator View

struct ShareCardGeneratorView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTemplate: ShareCardTemplate = .gradient
    @State private var showShareSheet = false
    @State private var generatedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Preview
                    if let weather = viewModel.weatherResponse {
                        ShareCardView(
                            weather: weather,
                            template: selectedTemplate,
                            useCelsius: viewModel.useCelsius
                        )
                        .cornerRadius(20)
                        .shadow(color: .white.opacity(0.1), radius: 20)
                    }
                    
                    // Template Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(ShareCardTemplate.allCases, id: \.self) { template in
                                TemplateButton(
                                    template: template,
                                    isSelected: selectedTemplate == template
                                ) {
                                    withAnimation {
                                        selectedTemplate = template
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Share Button
                    Button {
                        generateAndShare()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Teilen")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Story erstellen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = generatedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }
    
    private func generateAndShare() {
        guard let weather = viewModel.weatherResponse else { return }
        
        let cardView = ShareCardView(
            weather: weather,
            template: selectedTemplate,
            useCelsius: viewModel.useCelsius
        )
        
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0 // Hohe Auflösung
        
        if let image = renderer.uiImage {
            generatedImage = image
            showShareSheet = true
        }
    }
}

struct TemplateButton: View {
    let template: ShareCardTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: template.backgroundColor,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    )
                
                Text(template.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .gray)
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
