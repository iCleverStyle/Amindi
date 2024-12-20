import SwiftUI

struct WeatherIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    let condition: Int
    
    var body: some View {
        let symbol = getWeatherSymbol()
        return Image(systemName: symbol)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                .yellow,
                .white
            )
            .font(.system(size: 36))
    }
    
    private func getWeatherSymbol() -> String {
        switch condition {
        case 0: return colorScheme == .dark ? "moon.stars.fill" : "sun.max.fill" // Ясно
        case 1...3: return colorScheme == .dark ? "cloud.moon.fill" : "cloud.sun.fill" // Переменная облачность
        case 45, 48: return "cloud.fog" // Туман
        case 51...55: return "cloud.drizzle" // Морось
        case 56...57: return "cloud.sleet" // Ледяная морось
        case 61...65: return "cloud.rain" // Дождь
        case 66...67: return "cloud.sleet" // Ледяной дождь
        case 71...77: return "cloud.snow" // Снег
        case 80...82: return "cloud.rain" // Ливень
        case 85...86: return "cloud.snow" // Снежный шторм
        case 95: return "cloud.bolt" // Гроза
        case 96...99: return "cloud.bolt.rain" // Гроза с градом
        default: return "cloud"
        }
    }
}

#Preview {
    WeatherIcon(condition: 0)
} 
