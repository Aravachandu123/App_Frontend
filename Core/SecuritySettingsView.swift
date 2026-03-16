import SwiftUI

struct SecuritySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var personalizedInsights = true
    @State private var anonymousAnalytics = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                // Header removed for standard navigation

                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // General Preferences Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text("General Preferences")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appText)
                            
                            SettingsNavRow(icon: "bell", title: "Notifications")
                            
                            NavigationLink(destination: ThemeSettingsView()) {
                                SettingsNavRow(icon: "moon", title: "Theme")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Privacy & Security Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Privacy & Security")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appText)
                            
                            SettingsToggleRow(
                                icon: "brain.head.profile",
                                title: "Personalized Health Insights",
                                subtitle: "Allow AI to provide tailored recommendations based on your data.",
                                isOn: $personalizedInsights
                            )
                            
                            SettingsToggleRow(
                                icon: "chart.xyaxis.line",
                                title: "Anonymous Usage Analytics",
                                subtitle: "Help improve the app by sharing anonymized interaction data.",
                                isOn: $anonymousAnalytics
                            )
                        }
                        
                        // Data Management Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Data Management")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appText)
                            
                            SettingsNavRow(icon: "square.and.arrow.down", title: "Download My Data")
                            
                            NavigationLink(destination: DeleteAccountView()) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.red)
                                    }
                                    
                                    Text("Delete Account")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red.opacity(0.5))
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

// MARK: - Components

struct SettingsNavRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSecondaryBackground)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.appText)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.appText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appSecondaryText)
        }
        .contentShape(Rectangle()) // Tappable
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSecondaryBackground)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.appText)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appText)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.appSecondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .appTint)) 
        }
    }
}


#Preview {
    SecuritySettingsView()
}