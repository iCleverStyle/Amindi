import SwiftUI

struct ForecastIcon: View {
    let temperature: Double
    let condition: Int
    
    var body: some View {
        VStack(spacing: 4) {
            WeatherIcon(condition: condition)
                .font(.system(size: 24))
            Text(String(format: "%+.1f°", temperature))
                .font(.system(size: 12, weight: .medium))
        }
        .padding(8)
        .background(
            Circle()
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
} 