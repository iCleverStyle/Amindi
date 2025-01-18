import SwiftUI

struct ForecastIcon: View {
    let temperature: Double
    let condition: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4)
                .frame(width: 70, height: 70)
            
            VStack(spacing: 4) {
                WeatherIcon(condition: condition, isForecast: true)
                    .font(.system(size: 24))
                Text(String(format: "%+.1f°", temperature))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
} 