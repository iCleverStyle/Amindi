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
                    sunriseOrSunsetIndicator(weather: weather, currentTime: currentTime, diameter: diameter, center: center, helpers: helpers)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    // Вспомогательная функция для вычисления разницы во времени
    private func calculateHoursDifference(from currentTime: Date, to targetTime: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: currentTime, to: targetTime)
        var hoursDifference = components.hour ?? 0
        
        // Если разница отрицательная и большая, значит переход через полночь
        if hoursDifference < -12 {
            hoursDifference += 24
        } else if hoursDifference > 12 {
            hoursDifference -= 24
        }
        
        return hoursDifference
    }
    
    // Выделяем логику индикатора восхода/захода солнца в отдельную функцию
    @ViewBuilder
    private func sunriseOrSunsetIndicator(weather: WeatherResponse, currentTime: Date, diameter: CGFloat, center: CGPoint, helpers: WeatherViewHelpers) -> some View {
        if let sunrise = helpers.parseTime(weather.daily.sunrise[0]),
           let sunset = helpers.parseTime(weather.daily.sunset[0]) {
            
            let isNight = helpers.isNightTime(for: currentTime)
            let targetTime = isNight ? sunrise : sunset
            
            // Вычисляем разницу во времени с учетом перехода через полночь
            let hoursDifference = calculateHoursDifference(from: currentTime, to: targetTime)
            
            // Показываем индикатор только если до события меньше 11 часов
            if abs(hoursDifference) < 11 {
                let position = helpers.getSunPosition(for: targetTime, radius: diameter * 0.5, center: center)
                
                SunIndicator(isNight: isNight)
                    .position(position)
                    .zIndex(1)
            } else {
                Color.clear.frame(width: 0, height: 0)
            }
        } else {
            Color.clear.frame(width: 0, height: 0)
        }
    }
}

// Выносим индикатор в отдельное представление
struct SunIndicator: View {
    let isNight: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.systemBackground))
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.1), radius: 2)
            
            Image(systemName: isNight ? "sunrise.fill" : "sunset.fill")
                .foregroundColor(.orange)
                .font(.system(size: 20))
        }
    }
} 
