//
//  ContentView.swift
//  Amidi
//
//  Created by Евгений on 09/12/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var weatherService = WeatherService()
    @State private var currentTime = Date()
    @State private var isLoading = false
    @State private var showWeather = false
    @State private var rotation = 0.0
    @State private var selectedLocation: Location = UserDefaults.standard.loadLocation() ?? .kutaisi
    @State private var showLocationSearch = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.clear
            
            if isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .tint(.blue)
            } else if showWeather {
                WeatherView(
                    weather: weatherService.currentWeather, 
                    currentTime: currentTime,
                    location: selectedLocation
                )
            } else {
                Button(action: fetchWeatherWithAnimation) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .systemGray6))
                        .frame(width: 300, height: 120)
                        .overlay(
                            HStack(spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text("Проверить погоду")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                    Text("в \(selectedLocation.name)")
                                        .font(.system(size: 34, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.yellow)
                                    .font(.system(size: 50))
                                    .rotationEffect(.degrees(rotation))
                                    .onAppear {
                                        withAnimation(
                                            .linear(duration: 3)
                                            .repeatForever(autoreverses: false)
                                        ) {
                                            rotation = 360
                                        }
                                    }
                            }
                            .padding()
                        )
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            
            // Кнопка выбора локации всегда видна поверх
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                if !isLandscape {  // Показываем только в портретной ориентации
                    VStack {
                        Spacer().frame(height: 50)  // Отступ сверху
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text(selectedLocation.name)
                            }
                            .padding(8)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                            .cornerRadius(8)
                            .onTapGesture {
                                showLocationSearch = true
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)  // Добавляем центрирование
                        Spacer()
                    }
                    .frame(width: geometry.size.width)  // Задаем ширину равную ширине экрана
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .sheet(isPresented: $showLocationSearch) {
            LocationSearchView(
                selectedLocation: $selectedLocation,
                onLocationSelected: fetchWeatherWithAnimation
            )
        }
    }
    
    private func fetchWeatherWithAnimation() {
        isLoading = true
        showWeather = false  // Сбрасываем текущее отображение
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            await weatherService.fetchWeather(for: selectedLocation)
            isLoading = false
            showWeather = true
            
            try? await Task.sleep(for: .seconds(60))
            withAnimation {
                showWeather = false
            }
        }
    }
}

// Добавим протокол для общих функций
protocol WeatherViewHelpers {
    func getAngle(hour: Int, minute: Int) -> Double
    func getForecastData(weather: WeatherResponse, hours: Int) -> (temperature: Double, code: Int)?
    func getSunPosition(for date: Date, radius: CGFloat, center: CGPoint) -> CGPoint
    func parseTime(_ timeString: String) -> Date?
    func isNightTime(for date: Date) -> Bool
    func getIconPosition(currentTime: Date, radius: CGFloat, center: CGPoint) -> CGPoint
    func getBeaufortScale(speed: Double) -> String
}

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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone.current
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

// Обновим CircleView
private struct CircleView: View {
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
                            .frame(width: 90, height: 90)
                        
                        WeatherIcon(condition: weather.current.weatherCode, isNightTime: helpers.isNightTime(for: currentTime))
                            .font(.system(size: 32))
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

// Обновим WindView
private struct WindView: View {
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
                    // Флюгер
                    Image(systemName: "arrowshape.up")
                        .font(.system(size: 32))
                        .rotationEffect(.degrees(weather.current.windDirection10m))
                    
                    HStack {
                        Image(systemName: "wind")
                            .rotationEffect(.degrees(weather.current.windDirection10m - 90))
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
}

#Preview {
    ContentView()
}
