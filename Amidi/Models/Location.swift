import Foundation

struct Location: Codable, Identifiable, Equatable {
    var id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    
    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Реализация Equatable
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    }
    
    // Константы популярных локаций
    static let kutaisi = Location(
        name: "Кутаиси",
        latitude: 42.2679,
        longitude: 42.6946
    )
    
    static let tbilisi = Location(
        name: "Тбилиси",
        latitude: 41.7151,
        longitude: 44.8271
    )
    
    static let batumi = Location(
        name: "Батуми",
        latitude: 41.6459,
        longitude: 41.6459
    )
    
    // Вычисляемое свойство для формирования ключа кэша
    var cacheKey: String {
        return "\(latitude),\(longitude)"
    }
}

// Расширение для кодирования/декодирования
extension Location {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
    }
} 