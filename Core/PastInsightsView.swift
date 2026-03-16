import SwiftUI

struct PastInsightsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var riskStore = AppRiskStore.shared
    
    // UI Data structure
    struct InsightItem: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let icon: String
        let color: Color
    }
    
    // Dynamically computed insights based on real user data
    private var dynamicInsights: [InsightItem] {
        guard let latest = riskStore.latestRisk else {
            return []
        }
        
        // Map top risk areas to our InsightItem format
        var items = latest.topRiskAreas.map { domain in
            return InsightItem(
                title: "\(domain.riskLevel) \(domain.name) risk detected",
                description: domain.whyThisRisk,
                icon: RiskTheme.iconForDomain(domain.name),
                color: RiskTheme.colorForRiskLevel(domain.riskLevel)
            )
        }
        
        // Add meta-insights if we have results
        items.append(InsightItem(
            title: "Risk profile updated",
            description: "Your risk assessment for \(latest.overall.riskLevel) risk has been synced with your latest data.",
            icon: "arrow.triangle.2.circlepath",
            color: .green
        ))
        
        // Add family insight if significant
        if let topInfluencer = latest.history.first?.dominantCategory {
             items.append(InsightItem(
                title: "Family history analyzed",
                description: "Your \(topInfluencer) medical history has been factored into your genetic baseline.",
                icon: "person.3.fill",
                color: .blue
            ))
        }
        
        return items
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if dynamicInsights.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 60))
                        .foregroundColor(.appSecondaryText.opacity(0.5))
                    
                    Text("No Insights Yet")
                        .font(.headline)
                        .foregroundColor(.appText)
                    
                    Text("Complete your first health assessment to see personalized genetic insights.")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(dynamicInsights) { item in
                            InsightCard(item: item)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Past Insights")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

struct InsightCard: View {
    let item: PastInsightsView.InsightItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(item.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.appText)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.appSecondaryText)
                    .lineLimit(3)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(20)
    }
}

#Preview {
    NavigationView {
        PastInsightsView()
    }
}