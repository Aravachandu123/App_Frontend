
import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var sessionManager: SessionManager
    
    // Assessment State
    @ObservedObject var riskStore = AppRiskStore.shared
    
    // Helpers relying on the new RiskResult
    private var riskResult: RiskResult? {
        riskStore.latestRisk
    }
    
    private var topDomains: [RiskDomain] {
        return riskResult?.topRiskAreas ?? []
    }
    
    // Removed getColorForAccent in favor of getRiskColor
    private func getRiskColor(level: String) -> Color {
        return RiskTheme.colorForRiskLevel(level)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) { // Increased spacing for breathability
                        
                        // 1. Genetic Risk Summary Card (Hero)
                        geneticRiskSummaryCard
                        
                        // 2. Key Contributors
                        keyContributorsSection
                        
                        // 3. Susceptibilities
                        susceptibilitiesSection
                        
                        // 4. Actions Section
                        actionsSection
                        
                        // Extra padding at the bottom for scrolling past the TabBar
                        Spacer(minLength: 120) 
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Extracted Subviews
    
    private var geneticRiskSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(languageManager.localizedString("OVERALL RISK"))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.appSecondaryText)
                        .tracking(1) // Letter spacing
                    
                    Text(riskResult?.overall.riskLevel ?? "Unknown")
                        .font(.system(size: 42, weight: .bold)) // Larger
                        .foregroundColor(getRiskColor(level: riskResult?.overall.riskLevel ?? "Unknown"))
                }
                
                Spacer()
                
                // DNA Icon Circle with Pulse Effect (Simulated)
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "waveform.path.ecg")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.orange)
                }
            }
            
            Text(languageManager.localizedString("Based on your genetic profile, lifestyle, and family history."))
                .font(.body)
                .foregroundColor(.appSecondaryText)
                .lineLimit(2)
                .padding(.top, 4)
            
            NavigationLink(destination: SimpleExplanationView()) {
                HStack {
                    Text(languageManager.localizedString("Understand your risk"))
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.appBackground)
                .foregroundColor(.appText)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color.appSecondaryBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var keyContributorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: languageManager.localizedString("Key Contributors (Family Influence)"))
            
            VStack(spacing: 16) {
                if let influence = riskResult?.familyInfluence, !influence.isEmpty {
                    ForEach(Array(influence.enumerated()), id: \.element.relation) { index, inf in
                        let colors: [Color] = [.purple, .blue, .orange, .cyan, .pink]
                        let itemColor = colors[index % colors.count]
                        ContributorRow(title: inf.relation.capitalized, value: Double(inf.influencePercent), icon: "person.fill", color: itemColor)
                    }
                } else {
                    Text("No family influence data")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                }
            }
            .padding(20)
            .background(Color.appSecondaryBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
    }
    
    private var susceptibilitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: languageManager.localizedString("Susceptibilities"))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                if topDomains.isEmpty {
                    Text("No data available.")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .padding(.horizontal, 20)
                } else {
                    HStack(spacing: 16) {
                        ForEach(topDomains, id: \.id) { domain in
                            NavigationLink(destination: DynamicInsightView(domain: domain)) {
                                SusceptibilityCard(
                                    title: domain.name,
                                    risk: domain.riskLevel,
                                    icon: RiskTheme.iconForDomain(domain.name),
                                    color: RiskTheme.colorForDomain(domain.name)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20) // For shadow
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: languageManager.localizedString("Recommended Actions"))
            
            VStack(spacing: 16) {
                NavigationLink(destination: ImmediateActionsView()) {
                    ActionListRow(
                        icon: "exclamationmark.shield.fill",
                        iconColor: .orange,
                        title: "Immediate Actions",
                        subtitle: "View recommended actions"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: AllRecommendationsView()) {
                    ActionListRow(
                        icon: "doc.text.magnifyingglass",
                        iconColor: .blue,
                        title: "Screenings",
                        subtitle: "View recommended tests"
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - API Integration
    
    // MARK: - Helpers
    
    // MARK: - Helpers
}

// MARK: - Subviews

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.footnote)
            .fontWeight(.bold)
            .foregroundColor(.appSecondaryText)
            .tracking(1)
            .padding(.leading, 4)
    }
}

struct ContributorRow: View {
    let title: String
    let value: Double
    let icon: String // Added icon
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.appText)
                
                Spacer()
                
                Text("\(Int(value))% Influence")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            // Modern thin progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.1))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * (CGFloat(value) / 100.0), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

struct SusceptibilityCard: View {
    let title: String
    let risk: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Icon Container
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            .padding(.bottom, 24)
            
            Spacer()
            
            // Text Area
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)
                    .lineLimit(1)
                
                Text(risk)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .frame(width: 145, height: 150, alignment: .topLeading)
        .background(Color.appSecondaryBackground) // Standard adaptive background
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct ActionListRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1)) // Lighter background
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.appSecondaryText)
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    InsightsView()
}