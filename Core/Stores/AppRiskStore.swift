import Foundation

final class AppRiskStore: ObservableObject {
    static let shared = AppRiskStore()

    @Published var latestRisk: RiskResult? {
        didSet {
            saveToUserDefaults()
        }
    }
    @Published var history: [RiskHistoryEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Updated key to avoid conflict with old data
    private let storageKey = "saved_risk_result_v2"
    
    private init() {
        // Automatically load from UserDefaults on initialization
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(RiskResult.self, from: data) {
            self.latestRisk = decoded
        }
        
        // Listen for sign out / account deletion to clear data
        NotificationCenter.default.addObserver(self, selector: #selector(clearData), name: .didSignOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearData), name: .didDeleteAccount, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func saveToUserDefaults() {
        if let latestRisk = latestRisk {
            if let encoded = try? JSONEncoder().encode(latestRisk) {
                UserDefaults.standard.set(encoded, forKey: storageKey)
            }
        } else {
            // Nullifying the stored value
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }
    
    @objc private func clearData() {
        self.latestRisk = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
