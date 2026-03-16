import SwiftUI

class FamilyHealthViewModel: ObservableObject {
    private var isLoadingFromServer = false
    @Published var conditionsByMember: [String: Set<String>] = [
        "Myself": [],
        "Father": [],
        "Mother": [],
        "Grandparents": [],
        "Siblings": []
    ] {
        didSet {
            if !isLoadingFromServer {
                saveLocally()
                saveConditions()
            }
        }
    }
    
    init() {
        loadconditions()
        NotificationCenter.default.addObserver(self, selector: #selector(resetData), name: .didDeleteAccount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetData), name: .didSignOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFamilyDataUpdated), name: NSNotification.Name("FamilyDataDidUpdate"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func resetData() {
        // Clear all conditions in memory
        conditionsByMember = [
            "Myself": [],
            "Father": [],
            "Mother": [],
            "Grandparents": [],
            "Siblings": []
        ]
        // Also ensure UserDefaults is empty for this key (redundant if SessionManager clears domain, but safe)
        UserDefaults.standard.removeObject(forKey: "family_conditions_data")
    }

    @AppStorage("userEmail") private var userEmail = ""
    
    @objc private func handleFamilyDataUpdated() {
        loadconditions()
    }
    
    // MARK: - API Integration
    
    private func saveConditions() {
        guard !userEmail.isEmpty else { return }
        
        // Convert to payload format arrays expected by backend
        let payload: [String: Any] = [
            "Myself": Array(conditionsByMember["Myself", default: []]),
            "Father": Array(conditionsByMember["Father", default: []]),
            "Mother": Array(conditionsByMember["Mother", default: []]),
            "Grandparents": Array(conditionsByMember["Grandparents", default: []]),
            "Siblings": Array(conditionsByMember["Siblings", default: []])
        ]
        
        NetworkManager.shared.request(endpoint: .updateFamily(email: userEmail, payload: payload)) { [weak self] (result: Result<EmptyResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    print("Family conditions successfully synced to backend.")
                    // Recalculate risk immediately so the frontend updates without needing an app restart
                    RiskService.shared.recalculateRisk(email: self.userEmail) { _ in }
                case .failure(let error):
                    print("Failed to sync family conditions: \(error)")
                }
            }
        }
    }
    
    private func loadconditions() {
        // We could fetch from backend here, but the standard fetch profile doesn't include it right now.
        // Usually we would hit a GET /family/<email> but there is no such route created in the backend plan in previous conversations. We just have POST.
        // Wait, if it doesn't get fetched, we might just continue saving it locally alongside sending to backend so it persists across fresh opens?
        // Let's keep the user defaults as local cache, AND send to backend.
        
        if let data = UserDefaults.standard.data(forKey: "family_conditions_data"),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            isLoadingFromServer = true
            self.conditionsByMember = decoded.mapValues { Set($0) }
            isLoadingFromServer = false
        }
    }
    
    // Call this inside toggleCondition to persist locally
    private func saveLocally() {
        let executableData = conditionsByMember.mapValues { Array($0) }
        if let encoded = try? JSONEncoder().encode(executableData) {
            UserDefaults.standard.set(encoded, forKey: "family_conditions_data")
        }
    }
    
    // Update main toggle
    func toggleCondition(member: String, condition: String) {
        if condition == "None" {
            if conditionsByMember[member]?.contains("None") == true {
                conditionsByMember[member]?.remove("None")
            } else {
                conditionsByMember[member]?.removeAll()
                conditionsByMember[member]?.insert("None")
            }
        } else {
            conditionsByMember[member]?.remove("None")
            if conditionsByMember[member]?.contains(condition) == true {
                conditionsByMember[member]?.remove(condition)
            } else {
                conditionsByMember[member, default: []].insert(condition)
            }
        }
        
        saveLocally()
        saveConditions()
    }
    
    // Helper to check if a condition is selected
    func hasCondition(member: String, condition: String) -> Bool {
        return conditionsByMember[member]?.contains(condition) ?? false
    }
}
