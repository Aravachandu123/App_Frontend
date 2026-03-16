import SwiftUI

struct PersonalHealthReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var riskStore = AppRiskStore.shared
    
    // User Data (Read-Only for Report)
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userAge") private var userAge = "0"
    @AppStorage("lifestyleActivity") private var selectedActivity = ""
    @AppStorage("lifestyleDiet") private var selectedDiet = ""
    @AppStorage("lifestyleSmoking") private var selectedSmoking = ""
    @AppStorage("userBloodType") private var userBloodType = "O+" 
    @AppStorage("userGender") private var userGender = "Male"
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personal Health Report")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Text("Generated on \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider().background(Color.gray)
                    
                    // 1. Personal Details
                    SectionHeader(title: "Patient Details")
                    
                    VStack(spacing: 0) {
                        ReportRowItem(label: "Name", value: userName)
                        Divider().background(Color.gray.opacity(0.2)).padding(.leading)
                        ReportRowItem(label: "Age", value: "\(userAge) Years")
                        Divider().background(Color.gray.opacity(0.2)).padding(.leading)
                        ReportRowItem(label: "Gender", value: userGender)
                        Divider().background(Color.gray.opacity(0.2)).padding(.leading)
                        ReportRowItem(label: "Blood Group", value: userBloodType.isEmpty ? "Not Set" : userBloodType)
                    }
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(12)
                    
                    // 2. Lifestyle Habits
                    SectionHeader(title: "Lifestyle Profile")
                    
                    VStack(spacing: 0) {
                        ReportRowItem(label: "Physical Activity", value: selectedActivity)
                        Divider().background(Color.gray.opacity(0.2)).padding(.leading)
                        ReportRowItem(label: "Dietary Habits", value: selectedDiet)
                        Divider().background(Color.gray.opacity(0.2)).padding(.leading)
                        ReportRowItem(label: "Smoking Status", value: selectedSmoking)
                    }
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(12)
                    
                    // 3. Risk Assessment Summary
                    SectionHeader(title: "Clinical Risk Summary")
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Overall Risk Score")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(riskStore.latestRisk?.overall.riskPercent ?? 0)%")
                                .fontWeight(.bold)
                                .foregroundColor(RiskTheme.colorForRiskLevel(riskStore.latestRisk?.overall.riskLevel ?? "Low"))
                        }
                        
                        Text("Score is calculated based on 50% Personal Medical History, 30% Family History, and 20% Lifestyle Score.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, -8)
                        
                        Divider().background(Color.gray.opacity(0.2))
                        
                        Text("Top Risk Identification")
                            .font(.headline)
                            .foregroundColor(.appText)
                        
                        HStack(spacing: 12) {
                            if let topRisks = riskStore.latestRisk?.topRiskAreas {
                                ForEach(topRisks, id: \.id) { domain in
                                    RiskTag(title: "\(domain.name) (\(domain.riskLevel))", color: getRiskColor(level: domain.riskLevel))
                                }
                            } else {
                                Text("No risk data available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // Footer
                    Text("This report is generated by GenCare Assist algorithms based on provided data. It is not a substitute for professional medical advice.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationTitle("Health Report")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    generateAndSharePDF()
                }) {
                    Image(systemName: "arrow.down.circle.fill") // Download icon
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.appTint) // Use tint color
                        .font(.system(size: 20))
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    
    private func getRiskColor(level: String) -> Color {
        return RiskTheme.colorForRiskLevel(level)
    }

    private func generateAndSharePDF() {
        let riskScore = riskStore.latestRisk?.overall.riskPercent ?? 0
        let topRisks = riskStore.latestRisk?.topRiskAreas.map { (name: $0.name, level: $0.riskLevel, color: getRiskColor(level: $0.riskLevel)) } ?? []
        
        // Convert SwiftUI Color to UIColor for PDFManager if needed, assuming PDFManager accepts UIColor or similar
        // If PDFManager expects a specific Tuple type, we might need adjustments.
        // Assuming the previous code `("Cardiac", "Moderate", .red)` used standard UI colors.
        
        let data = PDFManager.ReportData(
            userName: userName,
            userAge: userAge,
            userGender: userGender,
            userBloodType: userBloodType,
            activity: selectedActivity,
            diet: selectedDiet,
            smoking: selectedSmoking,
            score: "\(riskScore)%",
            risks: topRisks, // This assumes PDFManager accepts [(String, String, UIColor)]
            date: Date()
        )
        
        if let url = PDFManager.shared.generateReport(data: data) {
            self.pdfURL = url
            self.showShareSheet = true
        }
    }
}

// MARK: - Subviews
struct ReportRowItem: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.appText)
        }
        .padding()
    }
}

struct RiskTag: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(0.5), lineWidth: 1)
            )
    }
}

#Preview {
    NavigationView {
        PersonalHealthReportView()
    }
}