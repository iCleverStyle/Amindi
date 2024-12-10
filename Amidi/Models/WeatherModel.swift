struct WeatherResponse: Codable {
    let current: Current
    
    struct Current: Codable {
        let temperature2m: Double
        let windSpeed10m: Double
        let weatherCode: Int
        let windDirection10m: Double
        
        enum CodingKeys: String, CodingKey {
            case temperature2m = "temperature_2m"
            case windSpeed10m = "wind_speed_10m"
            case weatherCode = "weather_code"
            case windDirection10m = "wind_direction_10m"
        }
    }
} 