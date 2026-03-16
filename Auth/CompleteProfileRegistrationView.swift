import SwiftUI

struct CompleteProfileRegistrationView: View {
    @Binding var resetToLogin: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var fullName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var goToVerify = false
    @State private var underlineBackToLogin = false
    @State private var showSuccess = false
    
    @State private var isRegistering = false
    @State private var registrationError: String? = nil
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                        .foregroundColor(.appText)
                        .font(.system(size: 18, weight: .medium))
                    }
                    Spacer()
                    Text("Complete Profile Registration")
                        .foregroundColor(.appText)
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .frame(height: 56)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        InputField(title: "Full Name", placeholder: "Enter Full Name", text: $fullName)
                        InputField(title: "Phone Number", placeholder: "Enter Phone Number", text: $phone)
                        InputField(title: "Email ID", placeholder: "Enter Email ID", text: $email)
                        SecureInputField(title: "Password", placeholder: "Enter Password", text: $password)
                        SecureInputField(title: "Re-enter Password", placeholder: "Re-enter Password", text: $confirmPassword)
                        
                        Button {
                            guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty, password == confirmPassword else {
                                registrationError = "Please fill all fields and ensure passwords match."
                                return
                            }
                            
                            guard isValidEmail(email) else {
                                registrationError = "Please enter a valid email address."
                                return
                            }
                            
                            guard isValidPassword(password) else {
                                registrationError = "Password must be at least 8 characters, with 1 uppercase, 1 lowercase, 1 number, and 1 special character."
                                return
                            }
                            
                            isRegistering = true
                            registrationError = nil
                            
                            let payload: [String: Any] = [
                                "full_name": fullName,
                                "email": email,
                                "password": password,
                                "phone": phone
                            ]
                            
                            NetworkManager.shared.request(endpoint: .register(payload: payload)) { (result: Result<RegisterResponse, Error>) in
                                DispatchQueue.main.async {
                                    isRegistering = false
                                    switch result {
                                    case .success(_):
                                        withAnimation { showSuccess = true }
                                        UserDefaults.standard.set(true, forKey: "justRegistered")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            dismiss()
                                        }
                                    case .failure(let error):
                                        if case NetworkError.serverError(let msg) = error {
                                            registrationError = msg
                                        } else {
                                            registrationError = error.localizedDescription
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if isRegistering {
                                    ProgressView().tint(.white).padding(.trailing, 8)
                                }
                                Text(isRegistering ? "Signing Up..." : "Sign Up")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "#1380ec"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .disabled(isRegistering)
                        .padding(.top, 16)
                        
                        if let registrationError = registrationError {
                            Text(registrationError)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button {
                            underlineBackToLogin = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                dismiss()
                            }
                        } label: {
                            Text("Back to Login")
                                .foregroundColor(Color(hex: "#9dabb9"))
                                .underline(underlineBackToLogin)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            
            // Success Overlay
            if showSuccess {
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Registration Successful")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("Your account has been created successfully. You can now login.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.horizontal, 16)
                }
                .padding(30)
                .background(Color(hex: "#1c2531"))
                .cornerRadius(24)
                .shadow(radius: 20)
                .padding(40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear { underlineBackToLogin = false }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPred.evaluate(with: password)
    }
}

#Preview {
    NavigationStack {
        CompleteProfileRegistrationView(resetToLogin: .constant(false))
    }
}