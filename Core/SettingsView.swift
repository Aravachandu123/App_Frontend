import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var familyViewModel: FamilyHealthViewModel
    
    // Privacy Toggles
    @AppStorage("personalizedInsights") private var personalizedInsights = true
    @AppStorage("anonymousAnalytics") private var anonymousAnalytics = false
    
    // User Data for Report
    @AppStorage("userName") private var userName = ""
    @AppStorage("userAge") private var userAge = "0"
    @AppStorage("userGender") private var userGender = ""
    @AppStorage("userBloodType") private var userBloodType = ""
    @AppStorage("lifestyleActivity") private var selectedActivity = ""
    @AppStorage("lifestyleDiet") private var selectedDiet = ""
    @AppStorage("lifestyleSmoking") private var selectedSmoking = ""
    
    // PDF Generation State
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var isGenerating = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - General
                    SettingsSection(title: "General") {
                        NavigationLink(destination: NotificationsView()) {
                            SettingsRow(icon: "bell.fill", color: .red, title: "Notifications")
                        }
                        
                        
                        Divider().padding(.leading, 50)
                        
                        ToggleRow(
                            icon: "moon.fill",
                            color: .purple,
                            title: "Dark Mode",
                            isOn: Binding(
                                get: { themeManager.selectedTheme == .dark },
                                set: { themeManager.selectedTheme = $0 ? .dark : .light }
                            )
                        )
                    }
                    
                    // MARK: - Intelligence
                    SettingsSection(title: "Privacy & Intelligence") {
                        ToggleRow(
                            icon: "brain.head.profile",
                            color: .orange,
                            title: "Personalized Insights",
                            isOn: $personalizedInsights
                        )
                        
                        Divider().padding(.leading, 50)
                        
                        ToggleRow(
                            icon: "chart.bar.xaxis",
                            color: .green,
                            title: "Share Analytics",
                            isOn: $anonymousAnalytics
                        )
                        
                        if anonymousAnalytics {
                            Divider().padding(.leading, 50)
                            
                            Button(action: {
                                generateAndSharePDF()
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue)
                                            .frame(width: 30, height: 30)
                                        
                                        if isGenerating {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.6)
                                        } else {
                                            Image(systemName: "square.and.arrow.up.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Text(isGenerating ? "Generating Analytics PDF..." : "Share Analytics Report")
                                        .font(.body)
                                        .foregroundColor(.appText)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 4)
                    
                    // MARK: - Data Management
                    SettingsSection(title: "Data") {
                        NavigationLink(destination: DownloadDataView()) {
                            SettingsRow(icon: "square.and.arrow.down.fill", color: .blue, title: "Download Data")
                        }
                        
                        Divider().padding(.leading, 50)
                        
                        NavigationLink(destination: DeleteAccountView()) {
                            SettingsRow(icon: "trash.fill", color: .red, title: "Delete Account")
                        }
                    }
                    .padding(.top, 4)
                    
                    // Footer
                    Text("GenCare Assist v1.0.0")
                        .font(.caption)
                        .foregroundColor(.appSecondaryText)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func generateAndSharePDF() {
        isGenerating = true
        
        let riskScore = AppRiskStore.shared.latestRisk?.overall.riskPercent ?? 0
        let topRisks = AppRiskStore.shared.latestRisk?.topRiskAreas.prefix(3).map { 
            ($0.name, $0.riskLevel, RiskTheme.colorForRiskLevel($0.riskLevel))
        } ?? []
        
        // Group condition -> Array of members for influences
        var influenceMap: [String: [String]] = [:]
        for (member, conditions) in familyViewModel.conditionsByMember {
            if member == "Myself" { continue }
            for condition in conditions {
                influenceMap[condition, default: []].append(member)
            }
        }
        let conditionsInfluence = influenceMap.map { (condition: $0.key, members: $0.value.sorted()) }
            .sorted { $0.condition < $1.condition }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let data = PDFManager.AnalyticsReportData(
                score: "\(riskScore)/100",
                risks: topRisks,
                influences: conditionsInfluence,
                date: Date()
            )
            
            if let url = PDFManager.shared.generateAnalyticsReport(data: data) {
                self.pdfURL = url
                self.showShareSheet = true
            }
            
            isGenerating = false
        }
    }
}

// MARK: - Components

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.appSecondaryText)
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.appSecondaryBackground)
            .cornerRadius(12)
            // .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let color: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 30, height: 30)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.body)
                .foregroundColor(.appText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.appSecondaryBackground) // Ensure touch target
    }
}

struct ToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 30, height: 30)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.body)
                .foregroundColor(.appText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}