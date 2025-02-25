import SwiftUI

struct WindView: View {
    let weather: WeatherResponse
    let colorScheme: ColorScheme
    let diameter: CGFloat
    let helpers: WeatherViewHelpers
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Фоновая карта
                Image("Georgia Vector Map")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: diameter * 0.95)
                    .foregroundStyle(Color(colorScheme == .dark ? 
                        .white.opacity(1) :
                        .black.opacity(0.5)))
                    .padding(.bottom, diameter * 0.05)
                
                VStack(spacing: 10) {
                    // Флюгер - указывает КУДА дует ветер
                    Image(systemName: "arrowshape.up")
                        .font(.system(size: 32))
                        .rotationEffect(.degrees(weather.current.windDirection10m + 180))
                    
                    // Текстовое описание направления (откуда дует ветер)
                    Text("Ветер \(getWindDirectionText(weather.current.windDirection10m))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "wind")
                            // Иконка ветра показывает направление движения ветра
                            .rotationEffect(.degrees(weather.current.windDirection10m + 90))
                        Text("\(String(format: "%.1f", weather.current.windSpeed10m)) м/с")
                    }
                    .font(.title2)
                    
                    Text(helpers.getBeaufortScale(speed: weather.current.windSpeed10m))
                        .font(.caption)
                }
                .padding(.top, 60)
            }
        }
    }
    
    // Функция для получения текстового описания направления ветра
    private func getWindDirectionText(_ degrees: Double) -> String {
        let directions = ["С", "ССВ", "СВ", "ВСВ", "В", "ВЮВ", "ЮВ", "ЮЮВ", 
                          "Ю", "ЮЮЗ", "ЮЗ", "ЗЮЗ", "З", "ЗСЗ", "СЗ", "ССЗ"]
        let index = Int((degrees.truncatingRemainder(dividingBy: 360) + 11.25) / 22.5) % 16
        return directions[index]
    }
} 
