import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @Namespace private var animation // For the moving indicator
    @EnvironmentObject var languageManager: LanguageManager
    
    // Enum for Tabs
    enum Tab: String, CaseIterable {
        case home = "Home"
        case insights = "Insights"
        case history = "History"
        case profile = "Profile"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .insights: return "chart.bar.fill"
            case .history: return "clock.fill"
            case .profile: return "person.fill"
            }
        }
    }
    
    init() {
        // Hide default UITabBar
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .insights:
                    InsightsView()
                case .history:
                    HistoryView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Docked Tab Bar
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
                        // Haptic Feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            // Icon
                            Image(systemName: tab.icon)
                                .font(.system(size: 24))
                                .scaleEffect(selectedTab == tab ? 1.2 : 1.0) // Bouncier scale
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                                .symbolEffect(.bounce, value: selectedTab == tab) // iOS 17 symbol effect if available, or just ignored
                            
                            Text(languageManager.localizedString(tab.rawValue))
                                .font(.caption2)
                                .fontWeight(selectedTab == tab ? .bold : .medium)
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                                .opacity(selectedTab == tab ? 1 : 0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.appTint)
                                        .matchedGeometryEffect(id: "TabBackground", in: animation)
                                        .shadow(color: Color.appTint.opacity(0.3), radius: 8, x: 0, y: 4) // Glow effect
                                 }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8) // Lift up from bottom
            .background(.ultraThinMaterial) // Glassmorphism
            .cornerRadius(35)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            .padding(.bottom, 10) // Floating effect
        }
        .ignoresSafeArea(.keyboard) 
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MainTabView()
}