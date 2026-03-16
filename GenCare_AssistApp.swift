import SwiftUI

@main
struct GenCareAssistApp: App {
    @StateObject private var familyHealthViewModel = FamilyHealthViewModel()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var profileImageManager = ProfileImageManager()
    
    // @State private var isSplashFinished = false // Moved to SessionManager
    
    @State private var isAnalyzingFinished = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if sessionManager.isDeletingAccount {
                    LoadingView(isFinished: .constant(false), title: "Deleting Account...")
                } else if sessionManager.isSigningOut {
                    LoadingView(isFinished: .constant(false), title: "Signing Out")
                } else if sessionManager.isLoggedIn {
                    if !sessionManager.hasCompletedProfile {
                        PersonalDetailsView()
                    } else if !isAnalyzingFinished {
                        LoadingView(isFinished: $isAnalyzingFinished)
                            .onAppear {
                                if !sessionManager.userEmail.isEmpty {
                                    RiskService.shared.fetchInitialRisk(email: sessionManager.userEmail)
                                }
                            }
                    } else {
                        MainTabView()
                    }
                } else if !sessionManager.isSplashFinished {
                    SplashView(isFinished: $sessionManager.isSplashFinished)
                } else if !sessionManager.hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    LoginView()
                }
            }
            .id("\(sessionManager.isLoggedIn)_\(sessionManager.hasCompletedProfile)") // Force rebuild when login or profile state changes
            .environmentObject(familyHealthViewModel)
            .environmentObject(themeManager)
            .environmentObject(sessionManager)
            .environmentObject(languageManager)
            .environmentObject(profileImageManager)
            .preferredColorScheme(themeManager.selectedTheme.colorScheme)
            .onChange(of: sessionManager.isLoggedIn) { oldValue, newValue in
                if !newValue {
                    isAnalyzingFinished = false
                }
            }
        }
    }
}
