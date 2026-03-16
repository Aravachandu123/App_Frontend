import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    
    // Animation States
    @State private var drawShield: CGFloat = 0.0
    @State private var rotateLoader: Bool = false
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 20.0
    @State private var contentOpacity: Double = 1.0
    
    // Aesthetic Colors
    let shieldGradient = LinearGradient(
        colors: [Color(hex: "00C6FF").opacity(0.1), Color(hex: "0072FF").opacity(0.05)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    let borderGradient = LinearGradient(
        colors: [Color(hex: "00C6FF"), Color(hex: "0072FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Shield & DNA Animation
                ZStack {
                    // 1. Loading/Circling Ring
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            Color(hex: "00C6FF").opacity(0.3),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(rotateLoader ? 360 : 0))
                        .animation(
                            .linear(duration: 2.0).repeatForever(autoreverses: false),
                            value: rotateLoader
                        )
                    
                    // 2. Shield Container
                    ZStack {
                        // Shield Background
                        ShieldShape()
                            .fill(shieldGradient)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        // Internal DNA Animation (Masked)
                        DNAHelixAnimation()
                            .frame(width: 100, height: 160)
                            .mask(ShieldShape().padding(20)) // Keep DNA inside
                        
                        // Shield Border Drawing
                        ShieldShape()
                            .trim(from: 0, to: drawShield)
                            .stroke(
                                borderGradient,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                    }
                    .frame(width: 200, height: 240)
                }
                
                Spacer().frame(height: 50)
                
                // MARK: - Text Reveal
                VStack(spacing: 12) {
                    HStack(spacing: 0) {
                        ForEach(Array("GenCare Assist".enumerated()), id: \.offset) { index, letter in
                            Text(String(letter))
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundStyle(borderGradient) // Antigravity Blue Gradient
                                .opacity(textOpacity)
                                .animation(
                                    .easeOut(duration: 0.5)
                                    .delay(0.5 + Double(index) * 0.05),
                                    value: textOpacity
                                )
                                .offset(y: textOffset)
                                .animation(
                                    .easeOut(duration: 0.5)
                                    .delay(0.5 + Double(index) * 0.05),
                                    value: textOffset
                                )
                        }
                    }
                    .tracking(1.2)
                    
                    Text("Personalized AI Genetic Insights")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .tracking(0.5)
                        .opacity(textOpacity)
                        .animation(.easeOut(duration: 1.0).delay(1.5), value: textOpacity)
                }
                .offset(y: textOffset)
                
                Spacer()
                
                Text("2026 c powered by simats engineering")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 40)
                    .opacity(textOpacity)
                    .animation(.easeOut(duration: 1.0).delay(2.0), value: textOpacity)
            }
            .opacity(contentOpacity) // Master fade for content
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Step 1: Start Animations
        rotateLoader = true
        
        // Draw Shield
        withAnimation(.easeInOut(duration: 1.5)) {
            drawShield = 1.0
        }
        
        // Step 2: Trigger Text Animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            textOpacity = 1.0
            textOffset = 0
        }
        
        // Step 3: Finish (Simple Fade Out)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 0.0 // Fade out elements
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isFinished = true
                }
            }
        }
    }
}

// MARK: - Custom Shield Shape
struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Start top left
        path.move(to: CGPoint(x: 0, y: h * 0.1))
        
        // Top Curve
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.1),
            control: CGPoint(x: w * 0.5, y: -h * 0.05)
        )
        
        // Right side down
        path.addLine(to: CGPoint(x: w, y: h * 0.6))
        
        // Bottom Point
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control: CGPoint(x: w, y: h * 0.85)
        )
        
        // Left side up
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.6),
            control: CGPoint(x: 0, y: h * 0.85)
        )
        
        // Close path
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Procedural 3D DNA Helix (Updated Colors for White BG)
struct DNAHelixAnimation: View {
    let strandCount = 12
    let speed = 2.0
    @State private var phase: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let strandHeight = height / CGFloat(strandCount)
            
            ForEach(0..<strandCount, id: \.self) { i in
                let index = CGFloat(i)
                let relativeY = index * strandHeight + strandHeight / 2
                let progress = index / CGFloat(strandCount)
                
                DNAStrandRow(
                    width: width,
                    yPos: relativeY,
                    progress: progress,
                    phase: phase
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

struct DNAStrandRow: View {
    let width: CGFloat
    let yPos: CGFloat
    let progress: CGFloat
    var phase: CGFloat
    
    var body: some View {
        let angle = (progress * .pi * 2) + phase
        let x1 = (width / 2) + (width / 3) * sin(angle)
        let scale1 = 0.6 + 0.4 * cos(angle)
        let zIndex1 = cos(angle)
        
        let angle2 = angle + .pi
        let x2 = (width / 2) + (width / 3) * sin(angle2)
        let scale2 = 0.6 + 0.4 * cos(angle2)
        let zIndex2 = cos(angle2)
        
        ZStack {
            // Connector Line
            Path { path in
                path.move(to: CGPoint(x: x1, y: yPos))
                path.addLine(to: CGPoint(x: x2, y: yPos))
            }
            .stroke(
                LinearGradient(
                    colors: [Color(hex: "0072FF").opacity(0.4), Color(hex: "00C6FF").opacity(0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            
            // Strand 1 (Blue)
            Circle()
                .fill(Color(hex: "0072FF"))
                .frame(width: 10, height: 10)
                .scaleEffect(scale1)
                .position(x: x1, y: yPos)
                .zIndex(zIndex1)
            
            // Strand 2 (Cyan)
            Circle()
                .fill(Color(hex: "00C6FF"))
                .frame(width: 10, height: 10)
                .scaleEffect(scale2)
                .position(x: x2, y: yPos)
                .zIndex(zIndex2)
        }
    }
}

#Preview {
    SplashView(isFinished: .constant(false))
}
