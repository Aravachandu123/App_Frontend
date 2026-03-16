import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var underlineBackToLogin = false
    @State private var showNewPassword = false
    @State private var isVerifying = false
    @State private var showSuccess = false
    @State private var verificationError: String? = nil

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.appText)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 44, height: 44, alignment: .leading)
                    }
                    Spacer()
                    Text("Forgot Password")
                        .foregroundColor(.appText)
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 6)

                // Content
                VStack(spacing: 18) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appSecondaryBackground)

                        if email.isEmpty {
                            Text("Email ID")
                                .foregroundColor(.appSecondaryText)
                                .font(.system(size: 20, weight: .medium))
                                .padding(.horizontal, 22)
                        }

                        TextField("", text: $email)
                            .foregroundColor(.appText)
                            .font(.system(size: 20, weight: .medium))
                            .padding(.horizontal, 22)
                            .frame(height: 72)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                    .frame(height: 72)
                    .padding(.top, 22)
                    .padding(.horizontal, 18)

                    if let error = verificationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal, 18)
                    }

                    Button {
                        guard isValidEmail(email) else {
                            verificationError = "Please enter a valid email address."
                            return
                        }
                        
                        isVerifying = true
                        verificationError = nil
                        
                        // Check if email exists by fetching profile
                        NetworkManager.shared.request(endpoint: .getProfile(email: email)) { (result: Result<ProfileResponse, Error>) in
                            DispatchQueue.main.async {
                                isVerifying = false
                                switch result {
                                case .success(_):
                                    withAnimation {
                                        showSuccess = true
                                    }
                                    
                                    // Navigate after success message
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        showSuccess = false
                                        // Pass the verified email to the new password view
                                        // We can use AppStorage or State, but for now we'll just navigate
                                        // AppStorage("resetEmail") can be used if we want NewPasswordView to know who to reset
                                        UserDefaults.standard.set(email, forKey: "resetEmail")
                                        showNewPassword = true
                                    }
                                case .failure(_):
                                    verificationError = "Invalid email or user not found."
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if isVerifying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(isVerifying ? "Verifying..." : "Verify")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color(hex: "#1380ec"))
                        .foregroundColor(.white)
                        .cornerRadius(18)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .disabled(isVerifying || email.isEmpty)
                    .opacity((isVerifying || email.isEmpty) ? 0.7 : 1)

                    Button {
                        underlineBackToLogin = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            dismiss()
                        }
                    } label: {
                        Text("Back to Login")
                            .foregroundColor(.appSecondaryText)
                            .font(.system(size: 18, weight: .medium))
                            .underline(underlineBackToLogin)
                            .padding(.top, 10)
                    }

                    Spacer()
                }
            }
            
            // Success Overlay
            if showSuccess {
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    Text("Verified Successfully")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(Color(hex: "#1c2531"))
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showNewPassword) {
            NewPasswordView()
        }
    }
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    ForgotPasswordView()
}
