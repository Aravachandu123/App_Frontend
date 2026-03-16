import SwiftUI

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let categoryName: String // The internal ID or the displayed name
    let score: Int // Kept for interface backward compatibility, though we fetch from domain
    @ObservedObject var riskStore = AppRiskStore.shared
    
    @State private var animateChart = false
    
    // UI Helpers using RiskResult
    private var riskDomain: RiskDomain? {
        // Try to match by ID first, then by display name
        riskStore.latestRisk?.domains.first { $0.id.lowercased() == categoryName.lowercased() || $0.name.lowercased() == categoryName.lowercased() }
    }
    
    private var displayScore: Int {
        riskDomain?.riskPercent ?? score
    }
    
    private var riskLevel: String {
        riskDomain?.riskLevel ?? (displayScore >= 60 ? "High Risk" : (displayScore >= 30 ? "Moderate Risk" : "Low Risk"))
    }
    
    private var riskColor: Color {
        return RiskTheme.colorForRiskLevel(riskLevel)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Overall Health Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("OVERALL HEALTH")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.appSecondaryText)
                                
                                Text(riskLevel)
                                    .font(.title.weight(.bold))
                                    .foregroundColor(riskColor)
                            }
                            Spacer()
                            
                            // Circular Indicator
                            ZStack {
                                Circle()
                                    .stroke(Color.appSecondaryText.opacity(0.15), lineWidth: 8)
                                
                                Circle()
                                    .trim(from: 0, to: animateChart ? CGFloat(displayScore) / 100.0 : 0)
                                    .stroke(
                                        riskColor,
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeOut(duration: 1.5), value: animateChart)
                                
                                Text("\(displayScore)%")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.appText)
                            }
                            .frame(width: 70, height: 70)
                        }
                        
                        Text(getCategoryDescription())
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryText)
                            .lineSpacing(4)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appSecondaryBackground)
                            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // MARK: - Risk Analysis Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Risk Analysis")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.appText)
                        } icon: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        
                        Text(getRiskAnalysisText())
                            .font(.body)
                            .foregroundColor(.appSecondaryText)
                            .lineSpacing(4)
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                    }
                    
                    // MARK: - About Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("About \(riskDomain?.name ?? categoryName) Health")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.appText)
                        } icon: {
                            Image(systemName: "book.pages.fill")
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 20)
                        
                        Text(getAboutText())
                            .font(.body)
                            .foregroundColor(.appSecondaryText)
                            .lineSpacing(4)
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                    }

                    // MARK: - Preventive Suggestions
                    if let domain = riskDomain, !domain.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Preventive Suggestions")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.appText)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(domain.tips.indices, id: \.self) { index in
                                    SuggestionRow(
                                        icon: getIconForTip(index: index),
                                        color: getColorForTip(index: index),
                                        title: domain.tips[index],
                                        subtitle: getSubtitleForTip(index: index)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    } else {
                        // Default Mock suggestions if no tips provided by backend
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Preventive Suggestions")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.appText)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                SuggestionRow(
                                    icon: "waveform.path.ecg",
                                    color: .red,
                                    title: "Schedule annual ECG",
                                    subtitle: "Monitor heart rhythm regularly"
                                )
                                SuggestionRow(
                                    icon: "drop.fill",
                                    color: .blue,
                                    title: "Reduce daily sodium",
                                    subtitle: "Target < 2,300mg per day"
                                )
                                SuggestionRow(
                                    icon: "figure.walk",
                                    color: .green,
                                    title: "Increase Zone 2 Cardio",
                                    subtitle: "30 mins, 5x a week"
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("\(riskDomain?.name ?? categoryName) Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateChart = true
        }
    }
    
    // MARK: - Text Helpers
    private func getCategoryDescription() -> String {
        return riskDomain?.whyThisRisk ?? "Based on your genetic markers and lifestyle factors, we've identified a predisposition to \(categoryName.lowercased()) sensitivities."
    }
    
    private func getRiskAnalysisText() -> String {
        // Ideally from backend. Mocked for now to match screenshot if empty.
        let uniqueConditions = Array(Set(riskDomain?.selectedConditions ?? []))
        let conditions = uniqueConditions.joined(separator: ", ")
        if !conditions.isEmpty {
           return "Your profile shows a pattern related to \(conditions), contributing significantly to this score."
        }
        return "Your history shows a strong pattern of markers, contributing significantly to this score."
    }
    
    private func getAboutText() -> String {
        // Ideally from backend. Mocked for now.
        if categoryName.lowercased() == "cardiac" || categoryName.lowercased() == "cardiovascular" {
            return "Cardiovascular health refers to the efficient functioning of the heart and blood vessels, critical for long-term longevity and vitality."
        } else if categoryName.lowercased() == "neural" || categoryName.lowercased() == "neurological" {
             return "Neurological health involves the brain, spine, and nerves, essential for cognitive function and motor skills."
        }
        return "\(categoryName) health is critical for your overall well-being and long-term vitality. Maintaining healthy habits can significantly reduce risks."
    }
    
    // MARK: - Tip Design Helpers
    private func getIconForTip(index: Int) -> String {
        let icons = ["waveform.path.ecg", "drop.fill", "figure.walk", "star.fill", "heart.text.square.fill"]
        return icons[index % icons.count]
    }
    
    private func getColorForTip(index: Int) -> Color {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple]
        return colors[index % colors.count]
    }
    
    private func getSubtitleForTip(index: Int) -> String {
        let subtitles = ["Monitor regularly", "Recommended daily target", "Consistent routine", "General advice", "Health best practice"]
        return subtitles[index % subtitles.count]
    }
}

// Re-using the SuggestionRow from earlier or redefining it locally if we delete CardiacDetailsView
struct SuggestionRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.appText)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationView {
        CategoryDetailView(categoryName: "Cardiac", score: 45)
    }
}
