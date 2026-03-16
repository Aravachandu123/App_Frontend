import SwiftUI

class SessionManager: ObservableObject {
    @AppStorage("isLoggedIn") private var storedIsLoggedIn: Bool = false
    @AppStorage("rememberMe") var rememberMe: Bool = false
    @AppStorage("hasCompletedOnboarding_v2") private var storedHasCompletedOnboarding: Bool = false
    @AppStorage("hasCompletedProfile") private var storedHasCompletedProfile: Bool = false
    
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userId") var userId: Int = 0
    
    @Published var isLoggedIn: Bool = false {
        didSet { storedIsLoggedIn = isLoggedIn }
    }
    @Published var hasCompletedOnboarding: Bool = false {
        didSet { storedHasCompletedOnboarding = hasCompletedOnboarding }
    }
    @Published var hasCompletedProfile: Bool = false {
        didSet { storedHasCompletedProfile = hasCompletedProfile }
    }
    
    @Published var isSigningOut: Bool = false
    @Published var isDeletingAccount: Bool = false // New state for delete flow
    @Published var isSplashFinished: Bool = false // Controlled by SessionManager now
    
    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding_v2")
        
        // If they already have a set value for hasCompletedProfile use it, otherwise assume false
        if UserDefaults.standard.object(forKey: "hasCompletedProfile") != nil {
            self.hasCompletedProfile = UserDefaults.standard.bool(forKey: "hasCompletedProfile")
        } else {
            // Backfill: If they are already logged in from a previous app version, assume they have completed it
            self.hasCompletedProfile = self.isLoggedIn
        }
        
        if !rememberMe {
            isLoggedIn = false
        }
        
        // Backfill: If logged in, ensure onboarding is marked complete
        if isLoggedIn {
            hasCompletedOnboarding = true
        }
    }

    func signIn(isNewUser: Bool = false, email: String? = nil, id: Int? = nil) {
        withAnimation {
            if let email = email { self.userEmail = email }
            if let id = id { self.userId = id }
            
            isLoggedIn = true
            hasCompletedOnboarding = true
            if isNewUser {
                hasCompletedProfile = false
            } else {
                hasCompletedProfile = true
            }
        }
    }
    
    func completeProfile() {
        withAnimation {
            hasCompletedProfile = true
        }
    }
    
    func startSignOut() {
        withAnimation {
            isSigningOut = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Increased delay for visual effect
            self.signOut()
            self.isSigningOut = false
        }
    }
    
    private func signOut() {
        withAnimation {
            isLoggedIn = false
            userEmail = ""
            userId = 0
            
            // Clear all user-specific AppStorage values so they don't leak to next login
            let keysToRemove = [
                "userName", "userAge", "userGender", "userBloodType", "userPhone",
                "lifestyleActivity", "lifestyleDiet", "lifestyleSmoking"
            ]
            for key in keysToRemove {
                UserDefaults.standard.removeObject(forKey: key)
            }
            
            isSplashFinished = false
            
            // Notify other view models to clear their data on sign out
            NotificationCenter.default.post(name: .didSignOut, object: nil)
        }
        // hasCompletedOnboarding matches "Existing User" state, so we keep it true.
        // This ensures Sign Out -> Login (Skipping Onboarding).
    }
    
    func deleteAccount() {
        withAnimation {
            isDeletingAccount = true // Trigger loading screen
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Clear all UserDefaults/AppStorage
            if let domain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: domain)
            }
            
            withAnimation {
                // Re-initialize state to default clean state
                self.isLoggedIn = false
                self.rememberMe = false
                self.userEmail = ""
                self.userId = 0
                
                // User requested: Logo -> Login. We skip onboarding despite deleting data.
                self.hasCompletedOnboarding = true
                
                // Show Splash Screen again (Logo Page)
                self.isSplashFinished = false
                
                // Notify other view models to clear their data
                NotificationCenter.default.post(name: .didDeleteAccount, object: nil)
                
                self.isDeletingAccount = false
            }
        }
    }
}

extension Notification.Name {
    static let didDeleteAccount = Notification.Name("didDeleteAccount")
    static let didSignOut = Notification.Name("didSignOut")
}