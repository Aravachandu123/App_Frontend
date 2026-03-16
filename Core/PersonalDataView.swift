import SwiftUI

struct PersonalDataView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Persistent Data (Read-Only)
    @AppStorage("userName") private var userName = ""
    @AppStorage("userAge") private var userAge = "0"
    @AppStorage("userGender") private var userGender = ""
    @AppStorage("userBloodType") private var userBloodType = ""
    @AppStorage("userPhone") private var userPhone = ""
    @AppStorage("userEmail") private var userEmail = ""
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Profile Header Card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.appTint.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.appTint)
                        }
                        
                        VStack(spacing: 4) {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.appText)
                            
                            Text("Personal Health Profile")
                                .font(.subheadline)
                                .foregroundColor(.appSecondaryText)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    // Details Grid
                    VStack(spacing: 16) {
                        PersonalSectionHeader(title: "Basic Information")
                        
                        HStack(spacing: 16) {
                            InfoCard(icon: "calendar", title: "Age", value: "\(userAge) years", color: .purple)
                            InfoCard(icon: "figure.stand", title: "Gender", value: userGender.isEmpty ? "Not set" : userGender, color: .blue)
                        }
                        
                        InfoCard(icon: "drop.fill", title: "Blood Type", value: userBloodType.isEmpty ? "Not set" : userBloodType, color: .red)
                        
                        PersonalSectionHeader(title: "Contact Details")
                            .padding(.top, 10)
                        
                        InfoRow(icon: "phone.fill", label: "Phone", value: userPhone.isEmpty ? "Not set" : userPhone)
                        InfoRow(icon: "envelope.fill", label: "Email", value: userEmail.isEmpty ? "Not set" : userEmail)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Personal Data")
        .navigationBarTitleDisplayMode(.inline) // Changed to inline to match others
        .standardBackButton()
    }
}

// MARK: - Components

struct PersonalSectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.appText)
            Spacer()
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appSecondaryBackground)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(.appSecondaryText)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.appText)
            }
            Spacer()
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        PersonalDataView()
    }
}