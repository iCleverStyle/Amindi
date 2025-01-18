import SwiftUI

struct WeatherIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    let condition: Int
    let primaryColor: Color?
    let secondaryColor: Color?
    let isFilled: Bool
    
    init(
        condition: Int,
        primaryColor: Color? = nil,
        secondaryColor: Color? = nil,
        isFilled: Bool = true
    ) {
        self.condition = condition
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.isFilled = isFilled
    }
    
    var body: some View {
        let (symbol, colors) = getWeatherSymbol()
        return Image(systemName: symbol)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                primaryColor ?? colors.primary,
                secondaryColor ?? colors.secondary
            )
            .font(.system(size: 36))
    }
    
    private func getWeatherSymbol() -> (symbol: String, colors: (primary: Color, secondary: Color)) {
        let baseName: String
        let colors: (primary: Color, secondary: Color)
        
        switch condition {
        case 0:
            baseName = colorScheme == .dark ? "moon.stars" : "sun.max"
            colors = colorScheme == .dark ? 
                (.yellow, .white) :
                (.yellow, .orange)
            
        case 1...3:
            baseName = colorScheme == .dark ? "cloud.moon" : "cloud.sun"
            colors = colorScheme == .dark ?
                (.white, .yellow) :
                (.white, .yellow)
            
        case 45...49:
            baseName = "cloud.fog"
            colors = (.gray, .white)
            
        case 50...55:
            baseName = "cloud.drizzle"
            colors = (.blue, .gray)
            
        case 56...59:
            baseName = "cloud.sleet"
            colors = (.cyan, .white)
            
        case 60...65:
            baseName = "cloud.rain"
            colors = (.gray, .blue)
            
        case 66...69:
            baseName = "cloud.sleet"
            colors = (.cyan, .white)
            
        case 70...79:
            baseName = "cloud.snow"
            colors = (.gray, .white)
            
        case 80...85:
            baseName = "cloud.rain"
            colors = (.gray, .blue)
            
        case 86...89:
            baseName = "cloud.snow"
            colors = (.white, .blue)
            
        case 90...95:
            baseName = "cloud.bolt"
            colors = (.gray, .yellow)
            
        case 96...99:
            baseName = "cloud.bolt.rain"
            colors = (.white, .blue)
            
        default:
            baseName = "cloud"
            colors = (.gray, .white)
        }
        
        return (isFilled ? baseName + ".fill" : baseName, colors)
    }
}

#Preview {
    VStack(spacing: 20) {
        WeatherIcon(condition: 0)
        
        WeatherIcon(
            condition: 95,
            primaryColor: .blue,
            secondaryColor: .yellow,
            isFilled: true
        )
        
        WeatherIcon(condition: 55)
        
        WeatherIcon(condition: 61)
        
        WeatherIcon(condition: 95)
    }
} 
