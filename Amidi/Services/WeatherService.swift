import Foundation

/// Сервис для получения данных о погоде
/// Использует API open-meteo.com
@MainActor
class WeatherService: ObservableObject {
    /// Текущие данные о погоде
    @Published var currentWeather: WeatherResponse?
    
    /// Ошибка, если запрос не удался
    @Published var error: Error?
    
    // Кэширование результатов запросов
    private var cache: [String: (weather: WeatherResponse, timestamp: Date)] = [:]
    private let cacheValidityDuration: TimeInterval = 15 * 60 // 15 минут
    
    /// Получает данные о погоде для указанной локации
    /// - Parameter location: Локация, для которой нужно получить погоду
    func fetchWeather(for location: Location) async {
        // Проверяем кэш
        let cacheKey = "\(location.latitude),\(location.longitude)"
        if let cachedData = cache[cacheKey], 
           Date().timeIntervalSince(cachedData.timestamp) < cacheValidityDuration {
            self.currentWeather = cachedData.weather
            return
        }
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&current=temperature_2m,wind_speed_10m,weather_code,wind_direction_10m&hourly=temperature_2m,weather_code&daily=sunrise,sunset&wind_speed_unit=ms&forecast_days=2&timezone=auto"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
            self.currentWeather = weather
            
            // Сохраняем в кэш
            cache[cacheKey] = (weather, Date())
        } catch {
            self.error = error
        }
    }
    
    // Метод для очистки кэша
    func clearCache() {
        cache.removeAll()
    }
    
    func cleanup() {
        currentWeather = nil
        error = nil
        clearCache()
    }
} 