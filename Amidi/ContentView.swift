//
//  ContentView.swift
//  Amidi
//
//  Created by Евгений on 09/12/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()
    @State private var currentTime = Date()
    @State private var isLoading = false
    @State private var showWeather = false
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
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "cloud.sun")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                Text("Проверить погоду")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                            }
                        )
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private func fetchWeatherWithAnimation() {
        isLoading = true
        
        // Имитация загрузки в течение 1 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task {
                await weatherService.fetchWeather()
                isLoading = false
                showWeather = true
                
                // Скрыть данные через 1 минуту
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    withAnimation {
                        showWeather = false
                    }
                }
            }
        }
    }
}

struct WeatherView: View {
    let weather: WeatherResponse?
    let currentTime: Date
    
    private func getAngle(hour: Int, minute: Int) -> Double {
        let hour12 = hour % 12
        return -Double.pi / 2 + 2 * Double.pi * (Double(hour12) + Double(minute) / 60) / 12
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
                 
                        WeatherIcon(condition: weather.current.weatherCode)
                            .foregroundColor(.white)
                            .font(.system(size: diameter * 0.25))
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.7))
                                    .frame(width: diameter * 0.25, height: diameter * 0.25)
                            )
                            .position(iconPosition)
                        
                        
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
                                // Флюгер
                                Image(systemName: "arrowshape.up")
                                    .font(.system(size: 32))
                                    .rotationEffect(.degrees(weather.current.windDirection10m))
                                
                                HStack {
                                    Image(systemName: "wind")
                                    Text("\(String(format: "%.1f", weather.current.windSpeed10m)) м/с")
                                }
                                .font(.title2)
                                
                                Text(getBeaufortScale(speed: weather.current.windSpeed10m))
                                    .font(.caption)
                            }
                            .padding(.top, 20)
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
