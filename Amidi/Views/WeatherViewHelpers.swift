import SwiftUI

protocol WeatherViewHelpers {
    func getAngle(hour: Int, minute: Int) -> Double
    func getForecastData(weather: WeatherResponse, hours: Int) -> (temperature: Double, code: Int)?
    func getSunPosition(for date: Date, radius: CGFloat, center: CGPoint) -> CGPoint
    func parseTime(_ timeString: String) -> Date?
    func isNightTime(for date: Date) -> Bool
    func getIconPosition(currentTime: Date, radius: CGFloat, center: CGPoint) -> CGPoint
    func getBeaufortScale(speed: Double) -> String
} 