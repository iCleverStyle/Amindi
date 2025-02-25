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
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Используем более эффективный таймер с меньшей частотой обновления
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.clear
            
            mainContent
            
            // Кнопка выбора локации
            locationButton
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
        .onAppear {
            // Загружаем погоду при первом появлении
            if !showWeather && !isLoading {
                fetchWeatherWithAnimation()
            }
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    // Выделяем основной контент в отдельное вычисляемое свойство
    private var mainContent: some View {
        Group {
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
                weatherButton
            }
        }
    }
    
    // Выделяем кнопку погоды в отдельное вычисляемое свойство
    private var weatherButton: some View {
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
                        rotatingIcon
                    }
                    .padding()
                )
        }
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // Выделяем вращающуюся иконку в отдельное вычисляемое свойство
    private var rotatingIcon: some View {
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
    
    // Выделяем кнопку локации в отдельное вычисляемое свойство
    private var locationButton: some View {
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
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
        }
    }
    
    private func fetchWeatherWithAnimation() {
        // Проверяем, не выполняется ли уже загрузка
        guard !isLoading else { return }
        
        isLoading = true
        showWeather = false  // Сбрасываем текущее отображение
        
        Task { @MainActor in
            // Добавляем небольшую задержку для анимации
            try? await Task.sleep(for: .seconds(1))
            await weatherService.fetchWeather(for: selectedLocation)
            
            if let error = weatherService.error {
                errorMessage = "Не удалось загрузить данные о погоде: \(error.localizedDescription)"
                showError = true
                isLoading = false
            } else if weatherService.currentWeather != nil {
                isLoading = false
                showWeather = true
                
                // Автоматически скрываем погоду через минуту
                try? await Task.sleep(for: .seconds(60))
                withAnimation {
                    showWeather = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
