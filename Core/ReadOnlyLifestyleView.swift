import SwiftUI

struct ReadOnlyLifestyleView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Persistent Data (Read-Only access)
    @AppStorage("lifestyleActivity") private var selectedActivity = ""
    @AppStorage("lifestyleDiet") private var selectedDiet = ""
    @AppStorage("lifestyleSmoking") private var selectedSmoking = ""
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header Card
                    VStack(spacing: 12) {
                        Image(systemName: "figure.mind.and.body")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                            .padding(.bottom, 8)
                        
                        Text("Lifestyle Assessment")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Text("Your daily habits significantly influence your long-term health.")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    // Habits Grid
                    VStack(spacing: 16) {
                        HStack {
                            Text("Key Habits")
                                .font(.headline)
                                .foregroundColor(.appText)
                            Spacer()
                        }
                        
                        LifestyleCard(
                            title: "Dietary Habits",
                            value: selectedDiet,
                            icon: "leaf.fill",
                            color: .green,
                            description: "Impacts metabolic and cardiac health."
                        )
                        
                        LifestyleCard(
                            title: "Physical Activity",
                            value: selectedActivity,
                            icon: "figure.run",
                            color: .orange,
                            description: "Essential for cardiovascular fitness."
                        )
                        
                        LifestyleCard(
                            title: "Smoking Status",
                            value: selectedSmoking,
                            icon: "lungs.fill",
                            color: .gray, // Or red if smoker? keeping neutral/gray for now
                            description: "Major risk factor for respiratory issues."
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Lifestyle Habits")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

struct LifestyleCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appText)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(20)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        ReadOnlyLifestyleView()
    }
}