import SwiftUI

struct LanguageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    let languages = [
        ("English", "English (US)"),
        ("Spanish", "Español"),
        ("French", "Français"),
        ("German", "Deutsch"),
        ("Hindi", "हिन्दी"),
        ("Japanese", "日本語"),
        ("Italian", "Italiano"),
        ("Portuguese", "Português"),
        ("Arabic", "Arabic")
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                // Header removed for standard navigation

                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(languages, id: \.0) { language in
                            LanguageRow(
                                title: language.0,
                                subtitle: language.1,
                                isSelected: languageManager.selectedLanguage == language.0
                            ) {
                                languageManager.setLanguage(language.0)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

struct LanguageRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Mock Flag Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appSecondaryBackground)
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appText.opacity(0.1), lineWidth: 1)
                        )
                    
                    Image(systemName: "flag")
                        .foregroundColor(.appText)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appText)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.appSecondaryText)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding()
            .background(Color.clear)
        }
    }
}

#Preview {
    LanguageView()
}