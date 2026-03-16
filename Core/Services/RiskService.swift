import Foundation

final class RiskService {
    static let shared = RiskService()
    
    func recalculateRisk(email: String, completion: @escaping (Result<RiskResult, Error>) -> Void) {
        // 1) GET /bundle/<email>
        NetworkManager.shared.request(endpoint: .getBundle(email: email)) { (bundleResult: Result<BundleResponse, Error>) in
            switch bundleResult {
            case .success(let bundle):
                // 2) Parse and Save Bundle locally so AppStorage stays hydrated across launches
                DispatchQueue.main.async {
                    // Personal
                    UserDefaults.standard.set(bundle.personal.fullName, forKey: "userName")
                    UserDefaults.standard.set(bundle.personal.email, forKey: "userEmail")
                    if let phone = bundle.personal.phone { UserDefaults.standard.set(phone, forKey: "userPhone") }
                    if let age = bundle.personal.age {
                        UserDefaults.standard.set(age == 0 ? "" : String(age), forKey: "userAge")
                    }
                    if let gender = bundle.personal.gender { UserDefaults.standard.set(gender, forKey: "userGender") }
                    if let blood = bundle.personal.bloodType { UserDefaults.standard.set(blood, forKey: "userBloodType") }
                    
                    // Lifestyle
                    if let activity = bundle.lifestyle.activity { UserDefaults.standard.set(activity, forKey: "lifestyleActivity") }
                    if let diet = bundle.lifestyle.diet { UserDefaults.standard.set(diet, forKey: "lifestyleDiet") }
                    if let smoke = bundle.lifestyle.smoking { UserDefaults.standard.set(smoke, forKey: "lifestyleSmoking") }
                    
                    // Family History (ConditionsByMember array encoded as JSON data)
                    let familyDict: [String: [String]] = [
                        "Myself": bundle.familyHistory.myself ?? [],
                        "Father": bundle.familyHistory.father,
                        "Mother": bundle.familyHistory.mother,
                        "Grandparents": bundle.familyHistory.grandparents,
                        "Siblings": bundle.familyHistory.siblings
                    ]
                    if let encoded = try? JSONEncoder().encode(familyDict) {
                        UserDefaults.standard.set(encoded, forKey: "family_conditions_data")
                    }
                    
                    // Ensure the family view model knows to reload if it's currently in memory
                    NotificationCenter.default.post(name: NSNotification.Name("FamilyDataDidUpdate"), object: nil)
                }

                // 3) Convert BundleResponse to Dictionary payload
                guard let data = try? JSONEncoder().encode(bundle),
                      let payload = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "RiskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode bundle"])))
                    }
                    return
                }
                
                // 4) POST to /assess to let the backend calculate (and save to risk_history table)
                NetworkManager.shared.request(endpoint: .assessRisk(payload: payload)) { (assessResult: Result<RiskResult, Error>) in
                    switch assessResult {
                    case .success(let result):
                        DispatchQueue.main.async {
                            AppRiskStore.shared.latestRisk = result
                            completion(.success(result))
                        }
                        
                    case .failure(let error):
                        print("Failed to assess risk: \(error)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch bundle: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchInitialRisk(email: String) {
        recalculateRisk(email: email) { _ in }
        fetchRiskHistory(email: email)
    }
    
    func fetchRiskHistory(email: String) {
        NetworkManager.shared.request(endpoint: .getRiskHistory(email: email)) { (result: Result<[RiskHistoryEntry], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let history):
                    AppRiskStore.shared.history = history
                case .failure(let error):
                    print("Failed to fetch risk history: \(error)")
                }
            }
        }
    }
}
