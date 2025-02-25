import SwiftUI

struct WeatherView: View {
    @Environment(\.colorScheme) private var colorScheme
    let weather: WeatherResponse?
    let currentTime: Date
    let location: Location
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let diameter = isLandscape ? 
                min(geometry.size.width * 0.5, geometry.size.height) * 0.8 :
                min(geometry.size.width, geometry.size.height) * 0.8
            
            if isLandscape {
                // Горизонтальная ориентация
                HStack(spacing: 0) {
                    // Левая часть с кругом прогнозов
                    ZStack {
                        if let weather = weather {
                            // Температура
                            VStack {
                                Text(String(format: "%+.1f°", weather.current.temperature2m))
                                    .font(.system(size: diameter * 0.25))
                                    .foregroundColor(.primary)
                            }
                            .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)
                        }
                        
                        // Круг с прогнозами
                        CircleView(
                            weather: weather,
                            currentTime: currentTime,
                            diameter: diameter,
                            helpers: self
                        )
                            .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)
                    }
                    .frame(width: geometry.size.width * 0.5)
                    
                    // Правая часть с локацией и ветром
                    VStack(spacing: 20) {
                        // Локация
                        HStack {
                            Image(systemName: "location.fill")
                            Text(location.name)
                        }
                        .font(.title2)
                        
                        if let weather = weather {
                            // Информация о ветре
                            WindView(
                                weather: weather,
                                colorScheme: colorScheme,
                                diameter: diameter,
                                helpers: self
                            )
                        }
                    }
                    .frame(width: geometry.size.width * 0.5)
                }
            } else {
                // Вертикальная ориентация
                ZStack {
                    // Слой с температурой
                    if let weather = weather {
                        VStack {
                            Text(String(format: "%+.1f°", weather.current.temperature2m))
                                .font(.system(size: diameter * 0.25))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.5)
                    }
                    
                    // Круг с прогнозами
                    CircleView(
                        weather: weather,
                        currentTime: currentTime,
                        diameter: diameter,
                        helpers: self
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
                    // Информация о ветре
                    if let weather = weather {
                        WindView(
                            weather: weather,
                            colorScheme: colorScheme,
                            diameter: diameter,
                            helpers: self
                        )
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.9)
                    }
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: weather != nil)
    }
}

extension WeatherView: WeatherViewHelpers {
    func getAngle(hour: Int, minute: Int) -> Double {
        let hour12 = hour % 12
        return -Double.pi / 2 + 2 * Double.pi * (Double(hour12) + Double(minute) / 60) / 12
    }
    
    func getForecastData(weather: WeatherResponse, hours: Int) -> (temperature: Double, code: Int)? {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentTime)
        
        // Находим индекс текущего часа
        guard let currentTimeIndex = weather.hourly.time.firstIndex(where: { timeString in
            timeString.contains(String(format: "%02d:00", currentHour))
        }) else { return nil }
        
        // Вычисляем индекс для прогноза
        let forecastIndex = currentTimeIndex + hours
        
        // Проверяем, что индекс находится в пределах массива
        guard forecastIndex < weather.hourly.time.count else {
            // Если прогноз выходит за пределы текущего дня, берем данные с начала следующего дня
            let remainingHours = hours - (weather.hourly.time.count - currentTimeIndex)
            guard remainingHours < weather.hourly.time.count else { return nil }
            
            return (
                temperature: weather.hourly.temperature2m[remainingHours],
                code: weather.hourly.weatherCode[remainingHours]
            )
        }
        
        return (
            temperature: weather.hourly.temperature2m[forecastIndex],
            code: weather.hourly.weatherCode[forecastIndex]
        )
    }
    
    func getSunPosition(for date: Date, radius: CGFloat, center: CGPoint) -> CGPoint {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let angle = getAngle(hour: hour, minute: minute)
        
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
    func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter.cached(withFormat: "yyyy-MM-dd'T'HH:mm")
        return formatter.date(from: timeString)
    }
    
    func isNightTime(for date: Date) -> Bool {
        if let weather = weather,
           let sunrise = parseTime(weather.daily.sunrise[0]),
           let sunset = parseTime(weather.daily.sunset[0]) {
            return date < sunrise || date > sunset
        }
        return false
    }
    
    func getIconPosition(currentTime: Date, radius: CGFloat, center: CGPoint) -> CGPoint {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        let angle = getAngle(hour: hour, minute: minute)
        
        // Вычисляем позицию на окружности относительно центра
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
    func getBeaufortScale(speed: Double) -> String {
        switch speed {
        case 0...0.59: return "Штиль"
        case 0.6...1.59: return "Тихий"
        case 1.6...3.29: return "Лёгкий"
        case 3.3...5.49: return "Слабый"
        case 5.5...7.99: return "Умеренный"
        case 8.0...10.79: return "Свежий"
        case 10.8...13.89: return "Сильный"
        case 13.9...17.19: return "Крепкий"
        case 17.2...20.79: return "Очень крепкий"
        case 20.8...24.49: return "Шторм"
        case 24.5...28.49: return "Сильный шторм"
        case 28.5...32.69: return "Жестокий шторм"
        default: return "Ураган"
        }
    }
} 