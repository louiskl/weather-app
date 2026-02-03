import SwiftUI

@main
struct WeatherApp: App {
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weatherViewModel)
        }
    }
}
