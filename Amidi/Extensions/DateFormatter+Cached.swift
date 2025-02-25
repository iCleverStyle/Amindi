import Foundation

extension DateFormatter {
    private static var cachedFormatters = [String: DateFormatter]()
    
    static func cached(withFormat format: String, timeZone: TimeZone = .current) -> DateFormatter {
        let key = "\(format)_\(timeZone.identifier)"
        
        if let formatter = cachedFormatters[key] {
            return formatter
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        
        cachedFormatters[key] = formatter
        
        return formatter
    }
} 