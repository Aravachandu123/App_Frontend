import SwiftUI

struct HomeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var profileImageManager: ProfileImageManager
    @State private var healthScoreProgress: CGFloat = 0
    @ObservedObject var riskStore = AppRiskStore.shared
    @AppStorage("userName") private var userName: String = "User"
    @AppStorage("personalizedInsights") private var personalizedInsights = true
    
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var hasUnreadNotifications = true // Added to track unread status
    
    // Helpers relying on the new RiskResult
    private var riskResult: RiskResult? {
        riskStore.latestRisk
    }
    
    private var topRiskAreas: [RiskDomain] {
        return riskResult?.topRiskAreas ?? []
    }
    
    private func getColorForLevel(_ level: String) -> Color {
        return RiskTheme.colorForRiskLevel(level)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // MARK: - 1. Modern Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(languageManager.localizedString("Welcome back,"))
                                .font(.callout)
                                .foregroundColor(.appSecondaryText)
                            Text(userName.isEmpty ? "User" : userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: NotificationsView()) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.appText)
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                    
                                    if hasUnreadNotifications {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 10)
                                            .offset(x: -2, y: 2)
                                    }
                                }
                            }
                            
                            NavigationLink(destination: ProfileView()) {
                                if let image = profileImageManager.profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 42, height: 42)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.appSecondaryBackground, lineWidth: 2))
                                        .shadow(radius: 3)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 42, height: 42)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.appSecondaryBackground, lineWidth: 2))
                                        .shadow(radius: 3)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    
                    // MARK: - 2. Premium Health Score Card
                    NavigationLink(destination: RiskDetailsView()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.appSecondaryBackground) // Semantic Background
                                .shadow(color: Color.blue.opacity(0.15), radius: 20, x: 0, y: 10)
                            
                            HStack(spacing: 16) {
                                // Left Side: Text and Button
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(languageManager.localizedString("Overall Risk Score"))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color.appText) // Semantic text
                                    
                                    Text(languageManager.localizedString("Your current risk score is based on your health factors and lifestyle data."))
                                        .font(.system(size: 14))
                                        .foregroundColor(.appSecondaryText) // Semantic gray
                                        .lineSpacing(4)
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack(spacing: 4) {
                                        Text(languageManager.localizedString("View Details"))
                                            .font(.system(size: 14, weight: .semibold))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(Color.blue)
                                    .padding(.top, 4)
                                }
                                
                                Spacer()
                                
                                // Right Side: Progress Circle
                                ZStack {
                                    // Track
                                Circle()
                                    .stroke(getColorForLevel(riskResult?.overall.riskLevel ?? "Unknown").opacity(0.15), lineWidth: 10)
                                    .frame(width: 80, height: 80)
                                
                                // Fill
                                Circle()
                                    .trim(from: 0, to: healthScoreProgress)
                                    .stroke(getColorForLevel(riskResult?.overall.riskLevel ?? "Unknown"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: getColorForLevel(riskResult?.overall.riskLevel ?? "Unknown").opacity(0.8), radius: 8, x: 0, y: 0)
                                    
                                    // Score Text
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text("\(riskResult?.overall.riskPercent ?? 0)")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Color.appText) // Semantic Text
                                        Text("%")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color.appText) // Semantic Text
                                            .baselineOffset(2)
                                    }
                                }
                            }
                            .padding(24)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.98)
                    
                    // MARK: - 3. Risk Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text(languageManager.localizedString("Top Risk Areas"))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            if topRiskAreas.isEmpty {
                                Text(languageManager.localizedString("No risk data available."))
                                    .font(.subheadline)
                                    .foregroundColor(.appSecondaryText)
                                    .padding()
                            } else {
                                HStack(spacing: 20) {
                                    ForEach(topRiskAreas, id: \.id) { domain in
                                        NavigationLink(destination: CategoryDetailView(categoryName: domain.name, score: domain.riskPercent)) {
                                            ModernRiskCard(
                                                title: domain.name,
                                                icon: RiskTheme.iconForDomain(domain.name),
                                                color: RiskTheme.colorForDomain(domain.name),
                                                riskLevel: domain.riskLevel
                                            )
                                        }
                                        .buttonStyle(RiskCardButtonStyle(color: RiskTheme.colorForDomain(domain.name)))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                            }
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    // MARK: - 4. Recent Insights
                    if personalizedInsights {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(languageManager.localizedString("Recent Insights"))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.appText)
                                
                                Spacer()
                                
                                Text("Latest Insights")
                                    .font(.caption2.bold())
                                    .foregroundColor(.appSecondaryText)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.appSecondaryBackground)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            if topRiskAreas.isEmpty {
                                Text(languageManager.localizedString("No recent insights available."))
                                    .font(.subheadline)
                                    .foregroundColor(.appSecondaryText)
                                    .padding()
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(generateInsights(from: topRiskAreas, userName: userName), id: \.id) { insight in
                                        ModernInsightRow(
                                            title: insight.title,
                                            icon: insight.icon,
                                            color: insight.color,
                                            isAIGenerated: false
                                        )
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .onAppear {
            // Staggered Animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
                withAnimation(.easeOut(duration: 1.2)) {
                    healthScoreProgress = CGFloat(riskResult?.overall.riskPercent ?? 0) / 100.0
                }
            }
        }
    }
    // MARK: - Insight Data Model & Generation
    
    struct GeneratedInsight: Identifiable {
        let id = UUID()
        let title: String
        let domainName: String
        let riskPercent: Int
        let icon: String
        let color: Color
        let isFamilyInsight: Bool
    }
    
    private func generateInsights(from domains: [RiskDomain], userName: String) -> [GeneratedInsight] {
        var insights: [GeneratedInsight] = []
        
        // 1. Primary Risk Insight (Dynamic)
        if let topDomain = domains.first {
            insights.append(GeneratedInsight(
                title: "\(topDomain.name) profile updated successfully",
                domainName: topDomain.name,
                riskPercent: topDomain.riskPercent,
                icon: RiskTheme.iconForDomain(topDomain.name),
                color: RiskTheme.colorForDomain(topDomain.name),
                isFamilyInsight: false
            ))
        }
        
        // 2. Secondary Risk Insight (Dynamic)
        if domains.count > 1 {
            let secondDomain = domains[1]
            insights.append(GeneratedInsight(
                title: "No major changes in \(secondDomain.name) detected",
                domainName: secondDomain.name,
                riskPercent: secondDomain.riskPercent,
                icon: "info.circle.fill",
                color: .gray,
                isFamilyInsight: false
            ))
        }
        
        // 3. Family History Insight (Personalized)
        insights.append(GeneratedInsight(
            title: "Family history data analysis complete",
            domainName: "Family",
            riskPercent: 0,
            icon: "person.2.circle.fill",
            color: .gray,
            isFamilyInsight: true
        ))
        
        return insights
    }
}


// MARK: - Components

struct ModernRiskCard: View {
    let title: String
    let icon: String
    let color: Color
    let riskLevel: String // Keeping logic, but hidden in UI for cleaner look
    @EnvironmentObject var languageManager: LanguageManager
    
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
                
                Text(languageManager.localizedString("Analysis complete"))
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

struct ModernInsightRow: View {
    let title: String
    let icon: String
    let color: Color
    var isAIGenerated: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if isAIGenerated {
                    Text("INSIGHT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.appSecondaryText)
                        .tracking(0.3)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isAIGenerated ? .medium : .semibold)
                    .foregroundColor(.appText)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 8)
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 3)
    }
}

// Custom Button Style with Hover & Press Animation
struct RiskCardButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HoverScalingView(configuration: configuration, color: color)
    }
    
    struct HoverScalingView: View {
        let configuration: Configuration
        let color: Color
        @State private var isHovered = false
        
        var body: some View {
            configuration.label
                .scaleEffect(isHovered || configuration.isPressed ? 1.08 : 1.0)
                .shadow(
                    color: color.opacity(isHovered || configuration.isPressed ? 0.6 : 0.0),
                    radius: isHovered || configuration.isPressed ? 20 : 0,
                    x: 0, 
                    y: isHovered || configuration.isPressed ? 10 : 0
                )
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isHovered)
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: configuration.isPressed)
                .onHover { hovering in
                    isHovered = hovering
                }
        }
    }
}

#Preview {
    HomeView()
}
