import SwiftUI

struct OnboardingView: View {

    @State private var currentIndex = 0
    // @State private var goToLogin = false // Removed: Handled by SessionManager
    @EnvironmentObject var sessionManager: SessionManager

    private let pages: [(img: String, title: String, sub: String)] = [
        ("onboarding1",
         "Understand Your Genetic\nFuture",
         "Use AI to assess potential health risks based on\nfamily history and lifestyle."),

        ("onboarding2",
         "Health is a Family Journey",
         "Uncover inherited patterns and take control of\nyour long-term wellness today."),

        ("onboarding3",
         "Your Data, Fully Protected",
         "We use clinical-grade encryption to ensure your\ngenetic information stays private and secure.")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(0..<pages.count, id: \.self) { i in
                    let p = pages[i]
                    OnboardingPage(
                        imageName: p.img,
                        title: p.title,
                        subtitle: p.sub,
                        index: i,
                        total: pages.count,
                        isLast: i == pages.count - 1
                    ) {
                        if i < pages.count - 1 {
                            withAnimation { currentIndex = i + 1 }
                        } else {
                            completeOnboarding()
                        }
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Check for asset catalog image
            if let _ = UIImage(named: "onboarding1") {
                print("DEBUG: onboarding1 image FOUND in assets/bundle")
            } else {
                print("DEBUG: onboarding1 image NOT FOUND in assets/bundle")
                
                // Fallback check for raw file
                if let path = Bundle.main.path(forResource: "onboarding1", ofType: "png") {
                    print("DEBUG: onboarding1.png FILE FOUND at path: \(path)")
                } else {
                    print("DEBUG: onboarding1.png FILE NOT FOUND")
                }
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            sessionManager.hasCompletedOnboarding = true
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(SessionManager())
    }
}
