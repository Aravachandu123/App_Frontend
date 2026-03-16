import SwiftUI

struct ThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "System"
    
    let themes = ["System", "Light", "Dark"]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                // Header removed for standard navigation

                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(themes, id: \.self) { theme in
                            Button(action: { selectedTheme = theme }) {
                                HStack {
                                    Text(theme)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appText)
                                    
                                    Spacer()
                                    
                                    if selectedTheme == theme {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                }
                                .padding()
                                .background(Color.appSecondaryBackground)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

#Preview {
    ThemeView()
}