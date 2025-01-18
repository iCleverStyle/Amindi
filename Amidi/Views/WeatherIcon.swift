import SwiftUI

struct WeatherIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    let condition: Int
    let primaryColor: Color?
    let secondaryColor: Color?
    let isFilled: Bool
    
    init(
        condition: Int,
        primaryColor: Color? = nil,
        secondaryColor: Color? = nil,
        isFilled: Bool = true
    ) {
        self.condition = condition
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.isFilled = isFilled
    }
    
    var body: some View {
        let (symbol, colors) = getWeatherSymbol()
        return Image(systemName: symbol)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                primaryColor ?? colors.primary,
                secondaryColor ?? colors.secondary
            )
            .font(.system(size: 36))
    }
    
    private func getWeatherSymbol() -> (symbol: String, colors: (primary: Color, secondary: Color)) {
        let baseName: String
        let colors: (primary: Color, secondary: Color)
        
        switch condition {
        case 0: // Чистое небо
            baseName = colorScheme == .dark ? "moon.stars" : "sun.max"
            colors = colorScheme == .dark ? 
                (.yellow, .white) :
                (.yellow, .orange)
            
        case 1...3: // Переменная облачность
            baseName = colorScheme == .dark ? "cloud.moon" : "cloud.sun"
            colors = (.white, .yellow)
            
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
        
        return (isFilled ? baseName + ".fill" : baseName, colors)
    }
}

#Preview {
    VStack(spacing: 20) {
        WeatherIcon(condition: 66)
        
        WeatherIcon(condition: 77)
        
        WeatherIcon(condition: 80)
        
        WeatherIcon(condition: 85)
        
        WeatherIcon(condition: 95)
        
        WeatherIcon(condition: 96)
        
        WeatherIcon(condition: 66)
        
        
        
    }
} 
