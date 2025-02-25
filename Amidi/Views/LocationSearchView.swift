import SwiftUI

struct LocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationService = LocationService()
    @Binding var selectedLocation: Location
    let onLocationSelected: () -> Void
    
    @State private var searchText = ""
    @State private var locations: [Location] = []
    @State private var isSearching = false
    @State private var error: Error?
    
    // Добавляем предопределенные локации
    private let predefinedLocations = [
        Location.kutaisi,
        Location.tbilisi,
        Location.batumi
    ]
    
    // Добавляем debounce для поиска
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationView {
            List {
                // Секция с предопределенными локациями
                Section("Популярные города") {
                    ForEach(predefinedLocations) { location in
                        locationButton(for: location)
                    }
                }
                
                // Секция с результатами поиска
                Section("Результаты поиска") {
                    if isSearching {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if locations.isEmpty && !searchText.isEmpty {
                        Text("Ничего не найдено")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(locations) { location in
                            locationButton(for: location)
                        }
                    }
                }
            }
            .navigationTitle("Поиск города")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Введите название города")
            .onChange(of: searchText) { oldValue, newValue in
                // Отменяем предыдущий поисковый запрос
                searchTask?.cancel()
                
                guard !newValue.isEmpty else {
                    locations = []
                    return
                }
                
                // Создаем новый поисковый запрос с задержкой
                searchTask = Task {
                    // Добавляем задержку для debounce
                    try? await Task.sleep(for: .seconds(0.5))
                    
                    // Проверяем, не был ли запрос отменен
                    if !Task.isCancelled {
                        await performSearch(query: newValue)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Выделяем кнопку локации в отдельную функцию
    private func locationButton(for location: Location) -> some View {
        Button {
            selectedLocation = location
            UserDefaults.standard.saveLocation(location)
            dismiss()
            onLocationSelected()
        } label: {
            Text(location.name)
                .foregroundColor(.primary)
        }
    }
    
    // Выделяем поиск в отдельную функцию
    private func performSearch(query: String) async {
        isSearching = true
        do {
            locations = try await locationService.searchLocations(query: query)
        } catch {
            self.error = error
        }
        isSearching = false
    }
} 