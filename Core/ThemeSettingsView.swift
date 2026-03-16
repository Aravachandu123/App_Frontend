import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                // Header removed for standard navigation

                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Theme Options
                        VStack(spacing: 16) {
                            ForEach(AppTheme.allCases) { theme in
                                Button(action: {
                                    withAnimation {
                                        themeManager.selectedTheme = theme
                                    }
                                }) {
                                    HStack {
                                        Text(theme.rawValue)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.appText)
                                        
                                        Spacer()
                                        
                                        if themeManager.selectedTheme == theme {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.appTint)
                                        } else {
                                            Image(systemName: "circle")
                                                .font(.system(size: 22))
                                                .foregroundColor(.appSecondaryText)
                                        }
                                    }
                                    .padding(20)
                                    .background(Color.appSecondaryBackground)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                themeManager.selectedTheme == theme ? Color.appTint : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Preview / Info (Optional)
                        Text("Choose 'System' to match your device settings, or manually select Light or Dark mode.")
                            .font(.system(size: 14))
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(ThemeManager())
}