import SwiftUI

struct VerifyAccountView: View {
    @Binding var resetToLogin: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var code: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.appText)
                            .font(.system(size: 18, weight: .medium))
                    }
                    Spacer()
                    Text("Verify Account")
                        .foregroundColor(.appText)
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .frame(height: 56)
                .background(Color.appBackground)

                Spacer().frame(height: 28)

                VStack(spacing: 16) {
                    Text("Enter the code")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.appText)

                    Text("We sent a verification code to your email. Please enter it below to continue.")
                        .foregroundColor(.appText.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 22)

                    // OTP Boxes
                    HStack(spacing: 14) {
                        ForEach(0..<6, id: \.self) { index in
                            TextField("", text: $code[index])
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.appText)
                                .frame(width: 56, height: 64)
                                .background(Color.appSecondaryBackground)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.appText.opacity(0.1), lineWidth: 1)
                                )
                                .focused($focusedField, equals: index)
                                .onChange(of: code[index]) { oldValue, newValue in
                                    if newValue.count > 1 {
                                        code[index] = String(newValue.prefix(1))
                                    }
                                    if !newValue.isEmpty && index < 5 {
                                        focusedField = index + 1
                                    }
                                }
                        }
                    }

                    Spacer().frame(height: 18)

                    Button {
                        print("Resend Code tapped")
                    } label: {
                        Text("Resend Code")
                            .foregroundColor(Color(hex: "#007AFF"))
                            .font(.system(size: 18, weight: .medium))
                    }

                    Spacer()
                }
                .padding(.top, 10)

                // Verify Button
                Button {
                    resetToLogin = true
                } label: {
                    Text("Verify")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color(hex: "#1380ec"))
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    VerifyAccountView(resetToLogin: .constant(false))
}
