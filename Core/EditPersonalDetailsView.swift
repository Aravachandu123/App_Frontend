import SwiftUI

struct EditPersonalDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Persistent Data
    @AppStorage("userName") private var userName = ""
    @AppStorage("userAge") private var userAge = ""
    @AppStorage("userGender") private var userGender = ""
    @AppStorage("userBloodType") private var userBloodType = ""
    @AppStorage("userPhone") private var userPhone = ""
    @AppStorage("userEmail") private var userEmail = ""
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    
    // Options
    private let genders = ["Male", "Female", "Other"]
    private let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.appTint.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 32))
                                .foregroundColor(.appTint)
                        }
                        
                        Text("Edit Personal Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                    }
                    .padding(.top, 20)
                    
                    // Personal Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        PersonalSectionHeader(title: "Basic Information")
                        
                        CustomTextField(icon: "person.fill", title: "Full Name", text: $userName)
                        CustomTextField(icon: "calendar", title: "Age", text: $userAge, keyboardType: .numberPad)
                        
                        // Custom Pickers
                        HStack(spacing: 16) {
                            CustomPicker(icon: "figure.stand", title: "Gender", selection: $userGender, options: genders)
                            CustomPicker(icon: "drop.fill", title: "Blood Type", selection: $userBloodType, options: bloodTypes)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Contact Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        PersonalSectionHeader(title: "Contact Information")
                        
                        CustomTextField(icon: "phone.fill", title: "Phone", text: $userPhone, keyboardType: .phonePad)
                        CustomTextField(icon: "envelope.fill", title: "Email", text: $userEmail, keyboardType: .emailAddress)
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Save Button
                    Button(action: saveDetails) {
                        HStack {
                            if isSaving {
                                ProgressView().tint(.white).padding(.trailing, 8)
                            }
                            Text(isSaving ? "Saving..." : "Save Changes")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appTint)
                        .cornerRadius(16)
                        .shadow(color: Color.appTint.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
    
    private func saveDetails() {
        guard !sessionManager.userEmail.isEmpty else { return }
        
        isSaving = true
        errorMessage = nil
        
        // Ensure userAge is int
        let ageInt = Int(userAge) ?? 0
        
        let payload: [String: Any] = [
            "age": ageInt,
            "gender": userGender,
            "blood_type": userBloodType
        ]
        
        NetworkManager.shared.request(endpoint: .updateProfile(email: sessionManager.userEmail, payload: payload)) { (result: Result<EmptyResponse, Error>) in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    self.logProfileUpdate()
                    RiskService.shared.recalculateRisk(email: self.sessionManager.userEmail) { _ in }
                    self.dismiss()
                case .failure(let error):
                    if case NetworkError.serverError(let msg) = error {
                        self.errorMessage = msg
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    print("Error saving profile: \(error)")
                }
            }
        }
    }
    
    private func logProfileUpdate() {
        let payload: [String: Any] = [
            "email": sessionManager.userEmail,
            "title": "Profile Updated",
            "subtitle": "You have successfully updated your personal details.",
            "icon": "person.crop.circle.badge.checkmark",
            "color": "#00f2fe"
        ]
        NetworkManager.shared.request(endpoint: .addLog(payload: payload)) { (result: Result<EmptyResponse, Error>) in }
    }
}

// MARK: - Custom Input Components

struct CustomTextField: View {
    let icon: String
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.appSecondaryText)
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.appTint)
                    .frame(width: 24)
                
                TextField("Enter \(title)", text: $text)
                    .foregroundColor(.appText)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color.appSecondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appSecondaryText.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct CustomPicker: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.appSecondaryText)
                .padding(.leading, 4)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.appTint)
                    
                    Text(selection.isEmpty ? "Select" : selection)
                        .foregroundColor(selection.isEmpty ? .gray : .appText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.appSecondaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appSecondaryText.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditPersonalDetailsView()
    }
}