import SwiftUI

struct RiskDetailsView: View {
    @Environment(\.dismiss) var dismiss

    @State private var animatedProgress: CGFloat = 0.0
    @ObservedObject var riskStore = AppRiskStore.shared
    
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
                VStack(spacing: 30) {
                    
                    // MARK: - 1. Overall Score Header
                    VStack(spacing: 16) {
                        ZStack {
                            // Background Circle
                            Circle()
                                .stroke(Color.gray.opacity(0.15), lineWidth: 15)
                                .frame(width: 140, height: 140)
                            
                            // Progress Circle
                            Circle()
                                .trim(from: 0, to: animatedProgress)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            getColorForLevel(riskResult?.overall.riskLevel ?? "Unknown"),
                                            getColorForLevel(riskResult?.overall.riskLevel ?? "Unknown").opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 140, height: 140)
                                .animation(.easeOut(duration: 1.5), value: animatedProgress)
                                .shadow(color: getColorForLevel(riskResult?.overall.riskLevel ?? "Unknown").opacity(0.8), radius: 15, x: 0, y: 0)
                            
                            VStack(spacing: 4) {
                                Text("\(riskResult?.overall.riskPercent ?? 0)%")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.appText)
                                
                                Text(riskResult?.overall.riskLevel ?? "Unknown")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(getColorForLevel(riskResult?.overall.riskLevel ?? "Unknown"))
                            }
                        }
                        .padding(.top, 20)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                animatedProgress = CGFloat(riskResult?.overall.riskPercent ?? 0) / 100.0
                            }
                        }
                        
                        Text("Overall Risk Score")
                            .font(.headline)
                            .foregroundColor(.appSecondaryText)
                    }
                    
                    // MARK: - 2. Detailed Risk Breakdown (Using domains array)
                    VStack(spacing: 20) {
                        HStack {
                            Text("Top Risk Areas")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if topRiskAreas.isEmpty {
                            Text("No risk data available.")
                                .font(.subheadline)
                                .foregroundColor(.appSecondaryText)
                        } else {
                            ForEach(topRiskAreas, id: \.id) { domain in
                                NavigationLink(destination: CategoryDetailView(categoryName: domain.name, score: domain.riskPercent)) {
                                    ModernRiskDetailCard(
                                        icon: RiskTheme.iconForDomain(domain.name),
                                        title: domain.name,
                                        description: RiskTheme.descriptionForDomain(domain.name),
                                        riskLabel: domain.riskLevel,
                                        riskValue: "\(domain.riskPercent)% Risk",
                                        color: RiskTheme.colorForDomain(domain.name),
                                        progress: CGFloat(domain.riskPercent) / 100.0
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - 3. Action Buttons
                    VStack(spacing: 16) {
                        NavigationLink(destination: AllRecommendationsView()) {
                            HStack {
                                Text("View All Recommendations")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appTint)
                            .cornerRadius(16)
                            .shadow(color: Color.appTint.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        NavigationLink(destination: FamilyInsightDetailView(insightTitle: "Explore how your family's health history impacts your genetic risk assessment.")) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text("Family History Influence")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.appText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Risk Details")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}


struct ModernRiskDetailCard: View {
    let icon: String
    let title: String
    let description: String
    let riskLabel: String
    let riskValue: String
    let color: Color
    let progress: CGFloat
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Soft Icon Container
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.appText)
                        
                        Spacer()
                        
                        Text(riskValue)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Progress Bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text(riskLabel)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(20)
        // Subtle shadow, adaptive
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    RiskDetailsView()
}