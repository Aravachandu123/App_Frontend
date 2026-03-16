import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var sessionManager: SessionManager
    @ObservedObject var riskStore = AppRiskStore.shared
    @AppStorage("personalizedInsights") private var personalizedInsights = true
    
    private var riskHistory: [RiskHistoryEntry] {
        guard let latest = riskStore.history.first else { return [] }
        return [latest]
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text(languageManager.localizedString("History"))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.appText)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // MARK: - Recent Activity
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.localizedString("Recent Assessments"))
                                .font(.headline)
                                .foregroundColor(.appSecondaryText)
                                .padding(.horizontal, 24)
                            
                            if riskHistory.isEmpty {
                                VStack(spacing: 16) {
                                    MockHistoryCard(title: "Initial Assessment", detail: "Low Risk - 15%", icon: "doc.text.fill", color: .green)
                                    MockHistoryCard(title: "Cardiovascular Update", detail: "Moderate Risk - 45%", icon: "heart.fill", color: .orange)
                                    MockHistoryCard(title: "Metabolic Profile", detail: "Optimal - 8%", icon: "leaf.fill", color: .blue)
                                }
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(riskHistory, id: \.id) { item in
                                        ActivityCard(item: item)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // MARK: - Past Reports
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.localizedString("Reports"))
                                .font(.headline)
                                .foregroundColor(.appSecondaryText)
                                .padding(.horizontal, 24)
                            
                            NavigationLink(destination: PersonalHealthReportView()) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.appTint.opacity(0.15))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "doc.text.fill")
                                            .font(.title2)
                                            .foregroundColor(.appTint)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(languageManager.localizedString("Personal Health Report"))
                                            .font(.headline)
                                            .foregroundColor(.appText)
                                        
                                        Text(languageManager.localizedString("Tap to view details"))
                                            .font(.caption)
                                            .foregroundColor(.appSecondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.appSecondaryText)
                                }
                                .padding(16)
                                .background(Color.appSecondaryBackground)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal, 20)
                            
                            // Link to Past Insights
                             if personalizedInsights {
                                NavigationLink(destination: PastInsightsView()) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.purple.opacity(0.15))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "clock.arrow.circlepath")
                                                .font(.title2)
                                                .foregroundColor(.purple)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(languageManager.localizedString("Past Insights"))
                                                .font(.headline)
                                                .foregroundColor(.appText)
                                            
                                            Text(languageManager.localizedString("Review previous alerts"))
                                                .font(.caption)
                                                .foregroundColor(.appSecondaryText)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.appSecondaryText)
                                    }
                                    .padding(16)
                                    .background(Color.appSecondaryBackground)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 10)
                }
            }
        }
        // Removed validation onAppear since we rely on AppRiskStore mainly
    }
}

struct ActivityCard: View {
    let item: RiskHistoryEntry
    
    private var color: Color {
        return RiskTheme.colorForRiskLevel(item.overallRiskLevel)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: item.createdAt) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return item.createdAt
    }
    
    private var aiSummary: String {
        if let response = item.responseJson {
            return response.recommendations.highPriority.first ?? "Keep up the good work and maintain a healthy lifestyle."
        }
        return "No AI explanation available for this assessment."
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Date & Score
            HStack {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
                
                Spacer()
                
                Text("\(item.overallRiskPercent)%")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(color)
                    .cornerRadius(12)
            }
            
            // Risk Level & Dominant Category
            HStack(spacing: 8) {
                Image(systemName: RiskTheme.iconForRiskLevel(item.overallRiskLevel))
                    .foregroundColor(color)
                
                Text("\(item.overallRiskLevel)")
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            // Domains breakdown
            if let domains = item.riskBreakdown, !domains.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Domain Risks:")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.appSecondaryText)
                    
                    let sortedDomains = domains.sorted { $0.value > $1.value }
                    
                    if let topDomain = sortedDomains.first {
                        Text("\(topDomain.key) (\(topDomain.value)%)")
                            .font(.caption)
                            .foregroundColor(.appText)
                    }
                }
            } else {
                Text("Dominant Risk: \(item.dominantCategory)")
                    .font(.subheadline)
                    .foregroundColor(.appText)
            }
            
            Divider()
            
            // AI Explanation
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Summary:")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.appTint)
                
                Text(aiSummary)
                    .font(.caption)
                    .foregroundColor(.appText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Components

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Start point
        path.move(to: CGPoint(x: 0, y: height * 0.8))
        
        // Smooth curves approximating the user's image
        path.addCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.3),
            control1: CGPoint(x: width * 0.05, y: height * 0.3),
            control2: CGPoint(x: width * 0.1, y: height * 0.2)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.3, y: height * 0.7),
            control1: CGPoint(x: width * 0.2, y: height * 0.4),
            control2: CGPoint(x: width * 0.25, y: height * 0.7)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.4),
            control1: CGPoint(x: width * 0.35, y: height * 0.7),
            control2: CGPoint(x: width * 0.4, y: height * 0.4)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.7, y: height * 0.8),
            control1: CGPoint(x: width * 0.6, y: height * 0.4),
            control2: CGPoint(x: width * 0.65, y: height * 0.9)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.85, y: height * 0.2),
            control1: CGPoint(x: width * 0.75, y: height * 0.7),
            control2: CGPoint(x: width * 0.8, y: height * 0.1)
        )
        
         path.addCurve(
            to: CGPoint(x: width, y: height * 0.4),
            control1: CGPoint(x: width * 0.9, y: height * 0.3),
            control2: CGPoint(x: width * 0.95, y: height * 0.4)
        )
        
        return path
    }
}

struct UpdateLogRow: View {
    let icon: String
    let title: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ReportRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: "doc")
                .foregroundColor(.white)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "doc")
                .foregroundColor(.white)
        }
    }
}

struct MockHistoryCard: View {
    let title: String
    let detail: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                .fill(color.opacity(0.15))
                .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(detail)
                    .font(.body.weight(.bold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.appText)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HistoryView()
}