import SwiftUI

struct DynamicInsightView: View {
    let domain: RiskDomain
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(RiskTheme.colorForDomain(domain.name).opacity(0.15))
                                .frame(width: 88, height: 88)
                            
                            Image(systemName: RiskTheme.iconForDomain(domain.name))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(RiskTheme.colorForDomain(domain.name))
                        }
                        .padding(.top, 10)
                        
                        Text("\(domain.name) health analysis complete")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Score Badge
                        HStack {
                            Text("\(domain.riskLevel) - \(domain.riskPercent)%")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(RiskTheme.colorForRiskLevel(domain.riskLevel))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(RiskTheme.colorForRiskLevel(domain.riskLevel).opacity(0.15))
                        .clipShape(Capsule())
                    }
                    
                    // MARK: - Details Cards
                    VStack(spacing: 16) {
                        
                        // Analysis Summary Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.appTint)
                                Text("Analysis Summary")
                                    .font(.headline)
                                    .foregroundColor(.appText)
                                Spacer()
                            }
                            
                            Text(domain.whyThisRisk)
                                .font(.body)
                                .foregroundColor(.appSecondaryText)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        
                        // Matched Patterns Card
                        if !domain.selectedConditions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .foregroundColor(RiskTheme.colorForDomain(domain.name))
                                    Text("Matched Patterns")
                                        .font(.headline)
                                        .foregroundColor(.appText)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(domain.selectedConditions, id: \.self) { condition in
                                        HStack(alignment: .top, spacing: 12) {
                                            Circle()
                                                .fill(RiskTheme.colorForDomain(domain.name))
                                                .frame(width: 8, height: 8)
                                                .padding(.top, 6)
                                            
                                            Text(condition)
                                                .font(.body)
                                                .foregroundColor(.appSecondaryText)
                                                .lineSpacing(2)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        }
                        
                        // Recommendations Card
                        if !domain.tips.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Recommendations")
                                        .font(.headline)
                                        .foregroundColor(.appText)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(domain.tips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.system(size: 16))
                                                .padding(.top, 2)
                                            
                                            Text(tip)
                                                .font(.body)
                                                .foregroundColor(.appSecondaryText)
                                                .lineSpacing(2)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("\(domain.name) Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        DynamicInsightView(domain: RiskDomain(
            id: "cardiovascular",
            name: "Cardiac",
            icon: "heart.fill",
            accent: "softRed",
            riskPercent: 50,
            riskLevel: "High Risk",
            selectedConditions: ["Hypertension", "High Salt Diet"],
            whyThisRisk: "Elevated risk due to associated conditions or lifestyle factors.",
            tips: ["Monitor blood pressure regularly.", "Maintain a heart-healthy diet."]
        ))
    }
}
