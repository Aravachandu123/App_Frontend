import SwiftUI

struct EditHealthInfoView: View {
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
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.appTint)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        
                        Text("Edit Health Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Text("Update your personal and medical information to keep your insights accurate.")
                            .font(.body)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 30)
                    
                    // Data Cards Grid
                    LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                        
                        // 1. Family Data (Edit)
                        NavigationLink(destination: EditFamilyDataView()) {
                            EditCategoryCard(
                                title: "Family Data",
                                description: "Update Medical History",
                                icon: "person.3.fill",
                                color: .purple
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 2. Lifestyle (Edit)
                        NavigationLink(destination: EditLifestyleView()) {
                            EditCategoryCard(
                                title: "Lifestyle",
                                description: "Edit Habits",
                                icon: "figure.walk",
                                color: .orange
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 3. Personal Data (Edit)
                        NavigationLink(destination: EditPersonalDetailsView()) {
                            EditCategoryCard(
                                title: "Personal Data",
                                description: "Update Profile",
                                icon: "person.text.rectangle",
                                color: .blue
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    // Additional Info
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Changes are saved locally and secure.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

// MARK: - Edit Category Card
struct EditCategoryCard: View {
    let title: String
    let description: String
    let icon: String // SF Symbol
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon Circle
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                // Edit Pencil Icon
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color.opacity(0.7))
                    .padding(8)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
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
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appSecondaryText.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        EditHealthInfoView()
    }
}