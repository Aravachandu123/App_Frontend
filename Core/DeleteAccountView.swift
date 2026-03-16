import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var showConfirmation = false
    @State private var currentState: AppDeleteState = .idle
    
    enum AppDeleteState {
        case idle
        case holding // Wait 0.5s pause
        case animating // Deletion visualization
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    Spacer(minLength: 20)
                    
                    // 1. Warning Graphic
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 4)
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }
                    .padding(.top, 20)
                    
                    // 2. Warning Text
                    VStack(spacing: 16) {
                        Text("Delete your account?")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 12) {
                            Text("This action is permanent and cannot be undone.")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            
                            Text("All your personal health data, risk assessments, and history will be permanently erased from our servers.")
                                .foregroundColor(.appSecondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .font(.body)
                        .padding(.horizontal, 24)
                    }
                    
                    // 3. Consequences List
                    VStack(alignment: .leading, spacing: 16) {
                        ConsequenceRow(icon: "heart.slash.fill", text: "Health profile deleted")
                        ConsequenceRow(icon: "clock.arrow.circlepath", text: "History wiped")
                        ConsequenceRow(icon: "lock.slash.fill", text: "Login credentials removed")
                    }
                    .padding(24)
                    .background(Color.appSecondaryBackground)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // 4. Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            showConfirmation = true
                        }) {
                            HStack {
                                if currentState == .holding {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 8)
                                }
                                Text("Delete Account")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.red)
                            .cornerRadius(16)
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.scaleEffect)
                        .alert("Confirm Final Deletion", isPresented: $showConfirmation) {
                            Button("Delete Account", role: .destructive) {
                                startDeletionProcess()
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("There is no going back. Are you sure?")
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Keep Account")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.appText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.appSecondaryBackground)
                                .cornerRadius(16)
                        }
                        .disabled(currentState != .idle)
                        .buttonStyle(.scaleEffect)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
            .blur(radius: currentState == .animating ? 10 : 0)
            
            // Full Screen Animation Overlay
            if currentState == .animating {
                DeleteAccountAnimationView()
                    .transition(.opacity)
            }
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
    
    func startDeletionProcess() {
        withAnimation {
            currentState = .holding
        }
        
        // 1. Hold for 0.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                currentState = .animating
            }
            
            // 2. Play Deletion Animation for ~2.5s then Delete
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                sessionManager.deleteAccount()
            }
        }
    }
}

struct ConsequenceRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.red)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.appText)
        }
    }
}

struct DeleteAccountAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
            
            VStack(spacing: 40) {
                ZStack {
                    // Outer pulsing ring
                    Circle()
                        .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0 : 1)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Rotating incomplete red ring
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Central Icon (Shredder/Trash effect)
                    Image(systemName: "xmark.bin.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .symbolEffect(.bounce, value: isAnimating) // iOS 17 check, fallback to simple scale if needed
                }
                
                VStack(spacing: 8) {
                    Text("Deleting Account...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    Text("Erasing all data permanently.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    DeleteAccountView()
}
