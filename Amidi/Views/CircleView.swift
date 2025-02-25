import SwiftUI

struct CircleView: View {
    let weather: WeatherResponse?
    let currentTime: Date
    let diameter: CGFloat
    let helpers: WeatherViewHelpers
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Основной круг
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: diameter, height: diameter)
                    .position(center)
                
                // Иконка погоды на круге
                if let weather = weather {
                    let iconPosition = helpers.getIconPosition(currentTime: currentTime, radius: diameter * 0.5, center: center)
                    
                    ZStack {
                        Circle()
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                            )
                            .frame(width: 99, height: 99)
                        
                        WeatherIcon(condition: weather.current.weatherCode, isNightTime: helpers.isNightTime(for: currentTime))
                            .font(.system(size: 44))
                    }
                    .position(iconPosition)
                    
                    // Прогноз через 3 часа
                    if let forecast3h = helpers.getForecastData(weather: weather, hours: 3) {
                        let forecastTime = Calendar.current.date(byAdding: .hour, value: 3, to: currentTime) ?? currentTime
                        let iconPosition = helpers.getIconPosition(currentTime: forecastTime, radius: diameter * 0.5, center: center)
                        ForecastIcon(
                            temperature: forecast3h.temperature, 
                            condition: forecast3h.code,
                            isNightTime: helpers.isNightTime(for: forecastTime)
                        )
                        .position(iconPosition)
                    }
                    
                    // Прогноз через 6 часов
                    if let forecast6h = helpers.getForecastData(weather: weather, hours: 6) {
                        let forecastTime = Calendar.current.date(byAdding: .hour, value: 6, to: currentTime) ?? currentTime
                        let iconPosition = helpers.getIconPosition(currentTime: forecastTime, radius: diameter * 0.5, center: center)
                        ForecastIcon(
                            temperature: forecast6h.temperature, 
                            condition: forecast6h.code,
                            isNightTime: helpers.isNightTime(for: forecastTime)
                        )
                        .position(iconPosition)
                    }
                    
                    // Прогноз через 9 часов
                    if let forecast9h = helpers.getForecastData(weather: weather, hours: 9) {
                        let forecastTime = Calendar.current.date(byAdding: .hour, value: 9, to: currentTime) ?? currentTime
                        let iconPosition = helpers.getIconPosition(currentTime: forecastTime, radius: diameter * 0.5, center: center)
                        ForecastIcon(
                            temperature: forecast9h.temperature, 
                            condition: forecast9h.code,
                            isNightTime: helpers.isNightTime(for: forecastTime)
                        )
                        .position(iconPosition)
                    }
                    
                    // Индикатор восхода/захода солнца
                    if let sunrise = helpers.parseTime(weather.daily.sunrise[0]),
                       let sunset = helpers.parseTime(weather.daily.sunset[0]) {
                        
                        let isNight = helpers.isNightTime(for: currentTime)
                        let targetTime = isNight ? sunrise : sunset
                        
                        // Добавляем проверку разницы во времени
                        let hoursDifference = Calendar.current.dateComponents(
                            [.hour],
                            from: currentTime,
                            to: targetTime
                        ).hour ?? 0
                        
                        // Показываем индикатор только если до события меньше 11 часов
                        if abs(hoursDifference) < 11 {
                            let position = helpers.getSunPosition(for: targetTime, radius: diameter * 0.5, center: center)
                            
                            ZStack {
                                Circle()
                                    .fill(Color(UIColor.systemBackground))
                                    .frame(width: 40, height: 40)
                                    .shadow(color: .black.opacity(0.1), radius: 2)
                                
                                Image(systemName: isNight ? "sunrise.fill" : "sunset.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.orange, .yellow)
                                    .font(.system(size: 20))
                            }
                            .position(position)
                            .zIndex(1)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
} 
