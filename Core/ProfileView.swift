import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var profileImageManager: ProfileImageManager
    @EnvironmentObject var sessionManager: SessionManager
    
    @AppStorage("userName") private var userName: String = "User"
    @State private var isLoading = false
    
    @State private var showingImagePicker = false
    @ObservedObject var riskStore = AppRiskStore.shared
    
    // Placeholder image logic
    let profileImageName = "profile_placeholder"

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 1. Profile Header
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        ProfileHeader(name: userName, image: profileImageManager.profileImage)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 3. Menu Groups
                    VStack(spacing: 24) {
                        
                        // Health Management
                        MenuGroup(title: languageManager.localizedString("Health Management")) {
                            NavigationLink(destination: MyHealthDataView()) {
                                ProfileMenuRow(icon: "heart.fill", title: languageManager.localizedString("My Health Data"), color: .red)
                            }
                            
                            NavigationLink(destination: EditHealthInfoView()) {
                                ProfileMenuRow(icon: "pencil", title: languageManager.localizedString("Edit Health Info"), color: .blue)
                            }
                        }
                        
                        // Account & Settings
                        MenuGroup(title: languageManager.localizedString("Account & Settings")) {
                            NavigationLink(destination: SettingsView()) {
                                ProfileMenuRow(icon: "gearshape.fill", title: languageManager.localizedString("Settings & Privacy"), color: .gray)
                            }
                            
                            NavigationLink(destination: HelpSupportView()) {
                                ProfileMenuRow(icon: "questionmark.circle.fill", title: languageManager.localizedString("Help & Support"), color: .orange)
                            }
                            

                        }
                        
                        // Session (Sign Out)
                        MenuGroup(title: languageManager.localizedString("Session")) {
                            NavigationLink(destination: SignOutView()) {
                                ProfileMenuRow(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    title: languageManager.localizedString("Sign Out"),
                                    color: .red,
                                    isDestructive: true
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Version Info
                    Text("Version 1.0.0 • GenCare Assist")
                        .font(.caption)
                        .foregroundColor(.appSecondaryText)
                        .padding(.top, 10)
                        
                    // Bottom Spacer for TabBar
                    Spacer(minLength: 100)
                }
                .padding(.top, 10)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchProfile()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: Binding(
                get: { self.profileImageManager.profileImage },
                set: { newImage in
                    if let image = newImage {
                        self.profileImageManager.saveImage(image)
                    }
                }
            ), isPresented: $showingImagePicker)
        }
    }
    
    private func fetchProfile() {
        guard !sessionManager.userEmail.isEmpty else { return }
        
        isLoading = true
        NetworkManager.shared.request(endpoint: .getProfile(email: sessionManager.userEmail)) { (result: Result<ProfileResponse, Error>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.userName = profile.full_name
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                    // Keep default if it fails completely
                    if self.userName.isEmpty {
                        self.userName = "User"
                    }
                }
            }
        }
    }
}

// MARK: - Components

struct MenuGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.appSecondaryText)
                .padding(.leading, 8)
            
            VStack(spacing: 12) {
                content
            }
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let color: Color
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isDestructive ? .red : .appText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appSecondaryText.opacity(0.5))
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

struct ProfileHeader: View {
    let name: String
    let image: UIImage?
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 100, height: 100)
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .offset(y: 8)
                }
                
                // Edit Icon Badge with Edit functionality implied (or could add button)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.appBackground, lineWidth: 3))
                            .offset(x: 4, y: 4)
                    }
                }
                .frame(width: 100, height: 100)
            }
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

struct StatsRow: View {
    let riskLevel: String
    let score: String
    let status: String
    
    var body: some View {
        HStack(spacing: 12) {
            StatCard(value: riskLevel, unit: "Risk Level", icon: "waveform.path.ecg", color: .orange)
            StatCard(value: score, unit: "Health Score", icon: "heart.text.square.fill", color: .blue)
            StatCard(value: status, unit: "Status", icon: "checkmark.shield.fill", color: .green)
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.appSecondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}