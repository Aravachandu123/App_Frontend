import SwiftUI

struct DownloadDataView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var riskStore = AppRiskStore.shared
    
    // User Data for Report
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userAge") private var userAge = "0"
    @AppStorage("userGender") private var userGender = "Male"
    @AppStorage("userBloodType") private var userBloodType = "O+"
    
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
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.appTint)
                            .font(.system(size: 20))
                    }
                }
                .disabled(isGenerating)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func getRiskColor(level: String) -> Color {
        return RiskTheme.colorForRiskLevel(level)
    }

    private func generateAndSharePDF() {
        isGenerating = true
        
        let riskScore = riskStore.latestRisk?.overall.riskPercent ?? 0
        let topRisks = riskStore.latestRisk?.topRiskAreas.map { (name: $0.name, level: $0.riskLevel, color: getRiskColor(level: $0.riskLevel)) } ?? []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let data = PDFManager.ReportData(
                userName: userName,
                userAge: userAge,
                userGender: userGender,
                userBloodType: userBloodType,
                activity: selectedActivity,
                diet: selectedDiet,
                smoking: selectedSmoking,
                score: "\(riskScore)%",
                risks: topRisks,
                date: Date()
            )
            
            if let url = PDFManager.shared.generateReport(data: data) {
                self.pdfURL = url
                self.showShareSheet = true
            }
            
            isGenerating = false
        }
    }
}

#Preview {
    NavigationView {
        DownloadDataView()
    }
}
