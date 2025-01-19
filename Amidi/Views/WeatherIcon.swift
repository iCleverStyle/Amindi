import SwiftUI

struct WeatherIcon: View {
    let condition: Int
    var isForecast: Bool = false
    let isNightTime: Bool
    
    init(
        condition: Int,
        isForecast: Bool = false,
        isNightTime: Bool
    ) {
        self.condition = condition
        self.isForecast = isForecast
        self.isNightTime = isNightTime
    }
    
    var body: some View {
        let (baseName, colors) = getWeatherSymbol(condition: condition)
        
        Image(systemName: baseName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                isForecast ? 
                    Color.gray.opacity(0.7) :
                    colors.0,
                isForecast ? 
                    Color.gray.opacity(0.5) :
                    colors.1
            )
    }
    
    private func getWeatherSymbol(condition: Int) -> (symbol: String, colors: (primary: Color, secondary: Color)) {
        let baseName: String
        let colors: (primary: Color, secondary: Color)
        
        switch condition {
        case 0: // Чистое небо
            baseName = isNightTime ? "moon.stars" : "sun.max"
            colors = isNightTime ? 
                (.yellow, .white) :
                (.yellow, .orange)
            
        case 1...3: // Переменная облачность
            baseName = isNightTime ? "cloud.moon" : "cloud.sun"
            colors = isNightTime ?
                (.white, .yellow) :
                (.gray, .yellow)
            
        case 45, 48: // Туман
            baseName = "cloud.fog"
            colors = (.gray, .white)
            
        case 51, 53, 55: // Морось
            baseName = "cloud.drizzle"
            colors = (.gray, .blue)
            
        case 56, 57: // Замерзающая морось
            baseName = "cloud.sleet"
            colors = (.cyan, .white)
            
        case 61, 63, 65: // Дождь
            baseName = "cloud.rain"
            colors = (.blue, .gray)
            
        case 66, 67: // Замерзающий дождь
            baseName = "cloud.rain"
            colors = (.cyan, .cyan)
            
        case 71, 73, 75, 77: // Снег
            baseName = "cloud.snow"
            colors = (.gray, .cyan)
            
        case 80, 81, 82: // Ливень
            baseName = "cloud.heavyrain"
            colors = (.blue, .blue)
            
        case 85, 86: // Снежный ливень
            baseName = "cloud.snow"
            colors = (.gray, .blue)
            
        case 95: // Гроза
            baseName = "cloud.bolt"
            colors = (.gray, .yellow)
            
        case 96, 99: // Гроза с градом
            baseName = "cloud.bolt.rain"
            colors = (.blue, .blue)
            
        default:
            baseName = "cloud"
            colors = (.gray, .white)
        }
        
        return (isForecast ? baseName + ".fill" : baseName, colors)
    }
}

#Preview {
    VStack(spacing: 20) {
        WeatherIcon(condition: 66, isNightTime: false)
        WeatherIcon(condition: 77, isNightTime: true)
        WeatherIcon(condition: 80, isNightTime: false)
        WeatherIcon(condition: 85, isNightTime: true)
        WeatherIcon(condition: 95, isNightTime: false)
        WeatherIcon(condition: 96, isNightTime: true)
    }
} 
