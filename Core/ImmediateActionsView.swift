import SwiftUI

struct ImmediateActionsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                            .padding(.bottom, 8)
                        
                        Text("Immediate Actions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Text("Based on your genetic profile, these are the most impactful steps you can take right now.")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Action Cards
                    VStack(spacing: 16) {
                        if let highPriorityItems = AppRiskStore.shared.latestRisk?.recommendations.highPriority, !highPriorityItems.isEmpty {
                            let colors: [Color] = [.orange, .blue, .green, .purple, .pink]
                            let icons: [String] = ["exclamationmark.triangle.fill", "bolt.fill", "star.fill", "heart.text.square.fill", "leaf.fill"]
                            
                            ForEach(Array(highPriorityItems.enumerated()), id: \.offset) { index, item in
                                ImmediateActionCard(
                                    title: "Recommended Action",
                                    description: item,
                                    icon: icons[index % icons.count],
                                    color: colors[index % colors.count],
                                    priority: "High Priority"
                                )
                            }
                        } else {
                            Text("No immediate actions found.")
                                .font(.body)
                                .foregroundColor(.appSecondaryText)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Immediate Actions")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

struct ImmediateActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let priority: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 54, height: 54)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(priority)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.1))
                        .foregroundColor(color)
                        .cornerRadius(8)
                }
                
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.appSecondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Call to Action Link removed as requested
            }
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ImmediateActionsView()
}