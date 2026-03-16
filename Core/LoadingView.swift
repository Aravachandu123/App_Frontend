import SwiftUI

struct LoadingView: View {
    @Binding var isFinished: Bool
    var title: String? = nil
    
    // Animation States
    @State private var rotate1: Double = 0
    @State private var rotate2: Double = 0
    @State private var rotate3: Double = 0
    @State private var breathe: CGFloat = 1.0
    
    // New "Floating" States
    @State private var floatingOffset: CGFloat = 0
    @State private var shadowScale: CGFloat = 1.0
    @State private var shadowOpacity: Double = 0.4
    
    // Theme Colors (Deep & Vibrant "Intelligence" Palette)
    let c1 = Color(hex: "00C6FF") // Electric Blue
    let c2 = Color(hex: "5856D6") // Deep Purple
    let c3 = Color(hex: "FF2D55") // Vibrant Pink
    let c4 = Color(hex: "00F0FF") // Cyan Accent
    
    // Rotating Messages
    @State private var messageIndex = 0
    @State private var loadingDots = "" // For title animation
    let messages = [
        "Initializing GenCare Core...",
        "Calibrating Biometric Sensors...",
        "Analyzing Genomic Sequences...",
        "Securing Patient Data...",
        "Optimizing Neural Pathways...",
        "Syncing Health Records..."
    ]
    @State private var messageOpacity = 1.0

    var body: some View {
        ZStack {
            // 1. Background: Deep Void with Ambient Light
            Color(hex: "05050A").ignoresSafeArea() // Nearly Black
            
            // Artificial "Stars" / Particles (GenCare Colored)
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill([c1, c2, c3, c4].randomElement()!.opacity(Double.random(in: 0.3...0.7)))
                    .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 0.8)
                    .shadow(color: [c1, c2, c3].randomElement()!.opacity(0.3), radius: 5, x: 0, y: 0) // Glow
            }
            
            // Ambient aurora background
            ZStack {
                Circle().fill(c2.opacity(0.15)).frame(width: 400).blur(radius: 100).offset(x: -100, y: -100)
                Circle().fill(c1.opacity(0.1)).frame(width: 400).blur(radius: 100).offset(x: 100, y: 100)
            }
            .ignoresSafeArea()
            
            VStack {
                // Premium Branding Title
                HStack(spacing: 0) {
                    Text("GENCARE ASSIST")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .tracking(4)
                    
                    Text(loadingDots)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .tracking(4)
                        .frame(width: 50, alignment: .leading) // Fixed width to prevent jitter
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, c4.opacity(0.8), .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: c1.opacity(0.6), radius: 15, x: 0, y: 0) // Electric Glow
                .padding(.top, 80)
                .transition(.opacity.animation(.easeIn(duration: 1.0)))
                
                Spacer()
                
                // 2. The "Living Intelligence" Core
                ZStack {
                    // Dynamic Shadow (Simulates height)
                    Ellipse()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 140, height: 40)
                        .scaleEffect(shadowScale)
                        .opacity(shadowOpacity)
                        .blur(radius: 20)
                        .offset(y: 180) // Position below the core
                    
                    // Main Core Group
                    ZStack {
                        // Layer 1: Base Nebula (Slow Rotate)
                        AngularGradient(colors: [c2, c1, c2], center: .center)
                            .mask(Circle())
                            .blur(radius: 60)
                            .opacity(0.3)
                            .rotationEffect(.degrees(rotate1))
                            .scaleEffect(breathe * 1.1)
                        
                        // Layer 2: Radiant Strands (Medium Rotate, Additive)
                        AngularGradient(colors: [.clear, c1, .clear, c3, .clear, c2, .clear], center: .center)
                            .mask(Circle())
                            .blur(radius: 30)
                            .rotationEffect(.degrees(rotate2))
                            .blendMode(.plusLighter) // KEY: Glowing Effect
                            .opacity(0.6)
                        
                        // Layer 3: Sharp High-Energy Ring (Fast Rotate)
                        Circle()
                            .strokeBorder(
                                AngularGradient(colors: [c4.opacity(0), c4, c1, c4.opacity(0)], center: .center),
                                lineWidth: 3
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(rotate3))
                            .blur(radius: 5)
                            .overlay(
                                Circle().stroke(c4.opacity(0.3), lineWidth: 1)
                                    .frame(width: 200, height: 200)
                            )
                        
                        // Layer 4: Inner White Hot Core
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 140, height: 140)
                            .blur(radius: 40)
                            .blendMode(.overlay)
                    }
                    .frame(width: 300, height: 300)
                    .offset(y: floatingOffset) // Apply Levitation
                }
                
                Spacer()
                
                // 3. Premium Glass HUD
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                        
                        // Rotating Message
                        VStack(alignment: .leading, spacing: 2) {
                            Text(messages[messageIndex])
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(0.5)
                                .id("MessageText") // Ensure transition happens
                                .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                                .opacity(messageOpacity)
                            
                            // Risk Score Calculation
                            if messageIndex == 2 || messageIndex == 3 { // Show during analysis
                                Text("Calculating Risk Score: \(Int.random(in: 10...90))%...")
                                    .font(.caption2)
                                    .foregroundColor(c4)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.9)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: c1.opacity(0.2), radius: 20, x: 0, y: 10)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
            handleCompletion()
            startMessageRotation()
            startDotAnimation()
        }
    }
    
    private func startDotAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if isFinished { timer.invalidate(); return }
            
            var dotCount = loadingDots.count + 1
            if dotCount > 3 { dotCount = 0 }
            loadingDots = String(repeating: ".", count: dotCount)
        }
    }
    
    private func startAnimations() {
        // Slow Nebula
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotate1 = 360
        }
        
        // Radiant Strands
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotate2 = -360
        }
        
        // Energy Ring
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotate3 = 360
        }
        
        // Breathing
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            breathe = 1.15
        }
        
        // FLOATING LEVITATION (New)
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            floatingOffset = -20 // Move up
            shadowScale = 0.7 // Shadow shrinks as object goes up
            shadowOpacity = 0.2 // Shadow fades as object goes up
        }
    }

    private func startMessageRotation() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { timer in
            if isFinished { timer.invalidate(); return }
            
            withAnimation(.easeInOut(duration: 0.5)) {
                messageOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                messageIndex = (messageIndex + 1) % messages.count
                withAnimation(.easeInOut(duration: 0.5)) {
                    messageOpacity = 1
                }
            }
        }
    }
    
    private func handleCompletion() {
        if title == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { // Slightly longer to see messages
                withAnimation(.easeOut(duration: 0.5)) {
                    isFinished = true
                }
            }
        }
    }
}

#Preview {
    LoadingView(isFinished: .constant(false))
}