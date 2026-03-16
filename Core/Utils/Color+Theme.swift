import SwiftUI

extension Color {
    // Backgrounds
    static let appBackground = Color(UIColor.systemBackground) // White in Light, Black in Dark
    static let appSecondaryBackground = Color(UIColor.secondarySystemBackground) // Light Gray in Light, Dark Gray in Dark
    
    // Text
    static let appText = Color.primary // Black in Light, White in Dark
    static let appSecondaryText = Color.secondary // Gray
    
    // Accents (keep branding colors but maybe adapt if needed)
    static let appTint = Color(hex: "#1380EC")
}
