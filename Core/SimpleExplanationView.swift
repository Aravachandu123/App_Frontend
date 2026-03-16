import SwiftUI

struct SimpleExplanationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var riskStore = AppRiskStore.shared
    
    private var riskLevel: String {
        riskStore.latestRisk?.overall.riskLevel ?? "Moderate"
    }
    
    private var riskColor: Color {
        RiskTheme.colorForRiskLevel(riskLevel)
    }
    
    private var riskIcon: String {
        RiskTheme.iconForRiskLevel(riskLevel)
    }
    
    private var riskTitle: String {
        let level = riskLevel.lowercased()
        if level.contains("low") { return "Low Risk Profile" }
        if level.contains("high") { return "High Risk Profile" }
        return "Moderate Risk Profile"
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {

                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        
                        // Hero Section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(riskColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: riskIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(riskColor)
                            }
                            .padding(.top, 20)
                            
                            Text(riskTitle)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                                .multilineTextAlignment(.center)
                            
                            Text("What this means for you")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.appSecondaryText)
                        }
                        .padding(.bottom, 20)
                        
                        // Explanation Cards
                        VStack(spacing: 20) {
                            ExplanationDetailCard(
                                icon: "camera.macro",
                                color: .blue,
                                title: "It's a Snapshot",
                                description: "Your genes show a higher potential for certain conditions, but it's not a diagnosis. It's a starting point for prevention."
                            )
                            
                            ExplanationDetailCard(
                                icon: "person.3.fill",
                                color: .green,
                                title: "Heritage Matters",
                                description: "History from your parents plays a role. Knowing this helps target screenings earlier than usual."
                            )
                            
                            ExplanationDetailCard(
                                icon: "figure.run",
                                color: .purple,
                                title: "Actionable Future",
                                description: "Genetic risk results cannot be changed, but you can manage the impact through early detection and monitoring."
                            )
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                        
                        // Action Button
                        Button(action: { dismiss() }) {
                            Text("I Understand")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appTint)
                                .cornerRadius(16)
                                .shadow(color: Color.appTint.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

struct ExplanationDetailCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Column
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Text Column
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.appSecondaryText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSecondaryBackground)
        .cornerRadius(20)
        // Subtle shadow
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SimpleExplanationView()
}