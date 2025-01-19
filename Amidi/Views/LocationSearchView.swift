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
    
    var body: some View {
        NavigationView {
            List {
                if isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(locations) { location in
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
                }
            }
            .navigationTitle("Поиск города")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Введите название города")
            .onChange(of: searchText) { oldValue, newValue in
                guard !newValue.isEmpty else {
                    locations = []
                    return
                }
                
                Task {
                    isSearching = true
                    do {
                        locations = try await locationService.searchLocations(query: newValue)
                    } catch {
                        self.error = error
                    }
                    isSearching = false
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
} 