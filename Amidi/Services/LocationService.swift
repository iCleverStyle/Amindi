import Foundation

class LocationService: ObservableObject {
    private let baseURL = "https://geocoding-api.open-meteo.com/v1/search"
    
    func searchLocations(query: String) async throws -> [Location] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?name=\(encodedQuery)&count=5&language=ru") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        
        return response.results?.map { result in
            Location(name: result.name, latitude: result.latitude, longitude: result.longitude)
        } ?? []
    }
}

private struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
}

private struct GeocodingResult: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
} 