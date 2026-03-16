import SwiftUI

struct SignOutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    
    enum SignOutState {
        case idle
        case holding // The 0.5s pause
        case animating // The full animation
    }
    
    @State private var currentState: SignOutState = .idle

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // 1. Hero Illustration
                ZStack {
                    Circle()
                        .fill(Color.appSecondaryBackground)
                        .frame(width: 160, height: 160)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "door.left.hand.open")
                        .font(.system(size: 60))
                        .foregroundColor(.appTint)
                        .offset(x: 5) // Visual centering adjustment for this specific icon
                }
                .padding(.bottom, 10)
                
                // 2. Text Content
                VStack(spacing: 16) {
                    Text("Log out of GenCare Assist?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                        .multilineTextAlignment(.center)
                    
                    Text("Your health data is securely encrypted. We’ll see you back soon for your next update.")
                        .font(.body)
                        .foregroundColor(.appSecondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                // 3. Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        startSignOutProcess()
                    }) {
                        HStack {
                            if currentState == .holding {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            }
                            Text("Sign Out")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.red) // Destructive action color
                        .cornerRadius(16)
                        .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(currentState != .idle)
                    .buttonStyle(.scaleEffect)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
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
                .padding(.bottom, 20)
            }
            .blur(radius: currentState == .animating ? 10 : 0) // Blur background when animating
            
            // Full Screen Animation Overlay
            if currentState == .animating {
                SignOutAnimationView()
                    .transition(.opacity)
            }
        }
        .navigationTitle("Sign Out")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
    
    func startSignOutProcess() {
        withAnimation {
            currentState = .holding
        }
        
        // 1. Hold for 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                currentState = .animating
            }
            
            // 2. Play Animation for ~2.0 seconds then Sign Out
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                sessionManager.startSignOut()
            }
        }
    }
}

struct SignOutAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Animated Logout Icon
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Image(systemName: "arrow.right.square.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .offset(x: isAnimating ? 30 : 0) // Slide out effect
                        .opacity(isAnimating ? 0 : 1)    // Fade out effect
                        .animation(.easeIn(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
                }
                
                VStack(spacing: 8) {
                    Text("Signing Out...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    Text("See you soon!")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SignOutView()
}