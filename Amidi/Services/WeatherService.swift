import Foundation

@MainActor
class WeatherService: ObservableObject {
    @Published var currentWeather: WeatherResponse?
    @Published var error: Error?
    
    func fetchWeather(for location: Location) async {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&current=temperature_2m,wind_speed_10m,weather_code,wind_direction_10m&hourly=temperature_2m,weather_code&daily=sunrise,sunset&wind_speed_unit=ms&forecast_days=2&timezone=auto"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
            self.currentWeather = weather
        } catch {
            self.error = error
        }
    }
} 