import SwiftUI

struct StandardBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appText)
                .padding(8) // Increase touch area slightly
        }
    }
}

struct StandardBackButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    StandardBackButton()
                }
            }
    }
}

extension View {
    func standardBackButton() -> some View {
        self.modifier(StandardBackButtonModifier())
    }
}
