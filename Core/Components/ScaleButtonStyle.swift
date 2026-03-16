import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// Extension for easy access
extension ButtonStyle where Self == ScaleButtonStyle {
    static var scaleEffect: ScaleButtonStyle { ScaleButtonStyle() }
}
