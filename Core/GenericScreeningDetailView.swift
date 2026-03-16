import SwiftUI

struct GenericScreeningDetailView: View {
    let title: String
    let reason: String
    let description: String
    let frequency: String
    let icon: String
    let color: Color
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header Card
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SCREENING")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.appSecondaryText)
                                
                                Text(title)
                                    .font(.title2.weight(.bold)) // Adjusted size for potentially long titles
                                    .foregroundColor(.appText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(color.opacity(0.15))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(color)
                            }
                        }
                        
                        Divider()
                            .background(Color.appSecondaryText.opacity(0.2))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("FREQUENCY")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.appSecondaryText)
                                Text(frequency)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(color)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("REASON")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.appSecondaryText)
                                Text(reason)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.appText)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Label {
                            Text("About this screening")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.appText)
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(.appSecondaryText)
                            .lineSpacing(4)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    
                    // Placeholder for future content
                    VStack(alignment: .leading, spacing: 16) {
                         Text("What to Expect")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.appText)
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Standard procedure usually takes 30-60 minutes.")
                                .font(.subheadline)
                                .foregroundColor(.appSecondaryText)
                            Text("Consult your doctor for specific preparation instructions.")
                                .font(.subheadline)
                                .foregroundColor(.appSecondaryText)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                    
                    // Action Button removed as requested
                }
            }
        }
        .navigationTitle("Screening Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        GenericScreeningDetailView(
            title: "Genetic Counseling",
            reason: "Family History",
            description: "Discuss implications of carrier status before major life events. A genetic counselor can help you understand your risks and options.",
            frequency: "Once",
            icon: "person.2.fill",
            color: .purple
        )
    }
}