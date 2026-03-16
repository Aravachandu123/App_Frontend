import SwiftUI

struct MyHealthDataView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Modern Grid Layout
    let adaptiveColumns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header/Intro Text
                    VStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.appTint)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        
                        Text("My Health Data")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Text("Explore your personalized health metrics and history.")
                            .font(.body)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 30)
                    
                    // Data Cards Grid
                    LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                        
                        // 1. Family Data (Read Only)
                        NavigationLink(destination: FamilyDataView()) {
                            HealthCategoryCard(
                                title: "Family Data",
                                description: "Medical Heritage",
                                icon: "person.3.fill",
                                color: .purple
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 2. Lifestyle (Read Only)
                        NavigationLink(destination: ReadOnlyLifestyleView()) {
                            HealthCategoryCard(
                                title: "Lifestyle",
                                description: "Habits & Activity",
                                icon: "figure.walk",
                                color: .orange
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 3. Personal Data (Read Only)
                        NavigationLink(destination: PersonalDataView()) {
                            HealthCategoryCard(
                                title: "My Health",
                                description: "Personal Profile",
                                icon: "person.text.rectangle",
                                color: .blue
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    // Additional Info or Encouragement?
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Your data is encrypted and secure.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Health Data") // Simplified title for nav bar if needed
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

// MARK: - Modern Health Category Card
struct HealthCategoryCard: View {
    let title: String
    let description: String
    let icon: String // SF Symbol
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        // Subtle shadow + Glow on tap handled by button style usually
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appSecondaryText.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        MyHealthDataView()
    }
}