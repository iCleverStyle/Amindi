import Foundation

extension UserDefaults {
    private static let locationKey = "selectedLocation"
    
    func saveLocation(_ location: Location) {
        if let encoded = try? JSONEncoder().encode(location) {
            set(encoded, forKey: Self.locationKey)
        }
    }
    
    func loadLocation() -> Location? {
        guard let data = data(forKey: Self.locationKey),
              let location = try? JSONDecoder().decode(Location.self, from: data) else {
            return nil
        }
        return location
    }
} 