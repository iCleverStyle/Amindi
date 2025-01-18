struct WeatherResponse: Codable {
    let current: Current
    let hourly: Hourly
    
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
    
    struct Hourly: Codable {
        let time: [String]
        let temperature2m: [Double]
        let weatherCode: [Int]
        
        enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
        }
    }
} 