
import SwiftUI

struct AllRecommendationsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var riskStore = AppRiskStore.shared
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Intro Text
                        Text("Personalized actions created by GenCare Assist based on your risk profile.")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        
                        // 1. High Priority Section
                        if let highPriority = riskStore.latestRisk?.recommendations.highPriority, !highPriority.isEmpty {
                            RecommendationSectionView(
                                title: "High Priority",
                                icon: "exclamationmark.triangle.fill",
                                color: .red,
                                items: highPriority
                            )
                        }
                        
                        // 2. Moderate Priority
                        if let moderatePriority = riskStore.latestRisk?.recommendations.moderatePriority, !moderatePriority.isEmpty {
                            RecommendationSectionView(
                                title: "Moderate Priority",
                                icon: "stethoscope",
                                color: .orange,
                                items: moderatePriority
                            )
                        }
                        
                        // 3. Lifestyle Advice
                        if let lifestyleAdvice = riskStore.latestRisk?.recommendations.lifestyleAdvice, !lifestyleAdvice.isEmpty {
                            RecommendationSectionView(
                                title: "Lifestyle Advice",
                                icon: "leaf.fill",
                                color: .green,
                                items: lifestyleAdvice
                            )
                        }
                        
                        // Fallback if no recommendations
                        if (riskStore.latestRisk?.recommendations.highPriority.isEmpty ?? true) &&
                           (riskStore.latestRisk?.recommendations.moderatePriority.isEmpty ?? true) &&
                           (riskStore.latestRisk?.recommendations.lifestyleAdvice.isEmpty ?? true) {
                            Text("No specific recommendations at this time. Keep up the good work!")
                                .font(.body)
                                .foregroundColor(.appSecondaryText)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        
                        // Disclaimer Footer
                        Text("This tool provides suggestions based on data points and is not a substitute for professional medical advice.")
                            .font(.caption)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
        }
        .navigationTitle("Recommendations")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

struct RecommendationSectionView: View {
    let title: String
    let icon: String // SF Symbol Name
    let color: Color
    let items: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            // Card Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                
                Spacer()
            }
            .padding()
            .background(Color.appSecondaryBackground) // Header bg matches content bg or distinct?
            // Let's make entire card appSecondaryBackground to stand out from appBackground
            
            Divider()
                .background(Color.appText.opacity(0.05))
            
            // Items Loop
            VStack(alignment: .leading, spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(color)
                            .font(.system(size: 18))
                            .padding(.top, 2)
                        
                        Text(items[index])
                            .font(.subheadline) // Slightly larger than caption
                            .foregroundColor(.appText)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4) // Better readability
                        
                        Spacer()
                    }
                    .padding()
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 44) // Indent divider
                            .background(Color.appText.opacity(0.05))
                    }
                }
            }
        }
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2) // Soft shadow
    }
}

#Preview {
    AllRecommendationsView()
}
