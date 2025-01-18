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
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.clear
            
            if isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .tint(.blue)
            } else if showWeather {
                WeatherView(weather: weatherService.currentWeather, currentTime: currentTime)
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
                                    Text("в Кутаиси")
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
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private func fetchWeatherWithAnimation() {
        isLoading = true
        
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            await weatherService.fetchWeather()
            isLoading = false
            showWeather = true
            
            try? await Task.sleep(for: .seconds(60))
            withAnimation {
                showWeather = false
            }
        }
    }
}

struct WeatherView: View {
    @Environment(\.colorScheme) private var colorScheme
    let weather: WeatherResponse?
    let currentTime: Date
    
    private func getAngle(hour: Int, minute: Int) -> Double {
        let hour12 = hour % 12
        return -Double.pi / 2 + 2 * Double.pi * (Double(hour12) + Double(minute) / 60) / 12
    }
    
    private func getForecastData(weather: WeatherResponse, hours: Int) -> (temperature: Double, code: Int)? {
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
    
    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height) * 0.8
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            VStack {
                ZStack {
                    // Круг
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: diameter, height: diameter)
                    
                    // Иконка погоды на круге
                    if let weather = weather {
                        let iconPosition = getIconPosition(currentTime: currentTime, radius: diameter * 0.5, center: center)
                        
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                                )
                                .frame(width: 90, height: 90)
                            
                            ZStack {
                                
                                WeatherIcon(condition: weather.current.weatherCode)
                                    .font(.system(size: 32))
//                                Text(String(format: "%+.1f°", weather.current.temperature2m))
//                                        .font(.system(size: 14, weight: .medium))
//                                        .padding(.top, 60)
                                
                            }
                        }
                        .position(iconPosition)
                        
                        // Прогноз через 3 часа
                        if let forecast3h = getForecastData(weather: weather, hours: 3) {
                            let iconPosition = getIconPosition(currentTime: Calendar.current.date(byAdding: .hour, value: 3, to: currentTime) ?? currentTime, radius: diameter * 0.5, center: center)
                            ForecastIcon(temperature: forecast3h.temperature, condition: forecast3h.code)
                                .position(iconPosition)
                        }
                        
                        // Прогноз через 6 часов
                        if let forecast6h = getForecastData(weather: weather, hours: 6) {
                            let iconPosition = getIconPosition(currentTime: Calendar.current.date(byAdding: .hour, value: 6, to: currentTime) ?? currentTime, radius: diameter * 0.5, center: center)
                            ForecastIcon(temperature: forecast6h.temperature, condition: forecast6h.code)
                                .position(iconPosition)
                        }
                        
                        // Прогноз через 9 часов
                        if let forecast9h = getForecastData(weather: weather, hours: 9) {
                            let iconPosition = getIconPosition(currentTime: Calendar.current.date(byAdding: .hour, value: 9, to: currentTime) ?? currentTime, radius: diameter * 0.5, center: center)
                            ForecastIcon(temperature: forecast9h.temperature, condition: forecast9h.code)
                                .position(iconPosition)
                        }
                    }
                    
                    // Температура в центре
                    VStack {
                        // Температура
                        if let weather = weather {
                            Text(String(format: "%+.1f°", weather.current.temperature2m))
                                .font(.system(size: diameter * 0.25))
                        }
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Кутаиси")
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        // Информация о ветре
                        if let weather = weather {
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
                                        
                                        Text(getBeaufortScale(speed: weather.current.windSpeed10m))
                                            .font(.caption)
                                    }
                                    .padding(.top, 60)
                                }
                                .padding(.top, 20)
                            }
                        }
                    }
                }
            }
            .position(center)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: weather != nil)
    }
    
    private func getIconPosition(currentTime: Date, radius: CGFloat, center: CGPoint) -> CGPoint {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        let angle = getAngle(hour: hour, minute: minute)
        
        // Вычисляем позицию на окружности относительно центра
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
    private func getBeaufortScale(speed: Double) -> String {
        switch speed {
        case 0...0.5: return "Штиль"
        case 0.6...1.5: return "Тихий"
        case 1.6...3.2: return "Лёгкий"
        case 3.3...5.4: return "Слабый"
        case 5.5...7.9: return "Умеренный"
        case 8.0...10.7: return "Свежий"
        case 10.8...13.8: return "Сильный"
        case 13.9...17.1: return "Крепкий"
        case 17.2...20.7: return "Очень крепкий"
        case 20.8...24.4: return "Шторм"
        case 24.5...28.4: return "Сильный шторм"
        case 28.5...32.6: return "Жестокий шторм"
        default: return "Ураган"
        }
    }
}

#Preview {
    ContentView()
}
