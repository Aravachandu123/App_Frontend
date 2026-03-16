import Foundation

struct RegisterResponse: Codable {
    let message: String
    let user_id: Int
}

struct LoginResponse: Codable {
    let message: String
    let user: UserData
    
    struct UserData: Codable {
        let id: Int
        let full_name: String
        let email: String
        let phone: String
        let age: Int?
        let gender: String?
        let blood_type: String?
        let is_profile_complete: Bool
    }
}

struct ErrorResponse: Codable {
    let error: String
}

struct UserLog: Codable, Identifiable {
    let id: Int
    let action_title: String
    let action_subtitle: String
    let icon: String
    let color_hex: String
    let created_at: String
}

// MARK: - Profile Models
struct ProfileResponse: Codable {
    let id: Int
    let full_name: String
    let email: String
    let phone: String
    let age: Int?
    let gender: String?
    let blood_type: String?
}

struct RiskHistoryItem: Codable, Identifiable {
    let id: Int
    let overall_risk_percent: Int
    let overall_risk_level: String
    let dominant_category: String
    let risk_breakdown: [String: Int]?
    let created_at: String
}

struct RiskResponse: Codable {
    let overallRiskPercent: Int
    let overallRiskLevel: String
    let riskBreakdown: [String: Int]?
    let riskAnalysis: String?
    let aboutCategory: String?
    let dominantCategory: String?
    let preventiveSuggestions: [PreventiveSuggestion]?
    let immediateActions: [ImmediateAction]?
    let recommendations: RiskRecommendations?
    let recommendedScreenings: [RecommendedScreening]?
    let familyInfluence: FamilyInfluenceData?
    let otherConditionReview: [OtherConditionReview]?
}

struct PreventiveSuggestion: Codable {
    let title: String
    let subtitle: String
    let icon: String
    let color: String
}

struct ImmediateAction: Codable {
    let title: String
    let subtitle: String
    let tag: String
    let icon: String
    let priority: Int?
}

struct RiskRecommendations: Codable {
    let highPriority: [RecommendationItem]?
    let moderatePriority: [RecommendationItem]?
    let lifestyleAdvice: [RecommendationItem]?
    let maintenance: [RecommendationItem]?
}

struct RecommendationItem: Codable {
    let title: String
    let subtitle: String
}

struct RecommendedScreening: Codable {
    let id: Int
    let title: String
    let frequency: String
    let reason: String
    let description: String
    let about: String
    let expect: String
}

struct FamilyInfluenceData: Codable {
    let points: [String: Double]?
    let topInfluencer: String?
    let cards: [InfluenceCard]?
}

struct InfluenceCard: Codable {
    let title: String
    let description: String
}

struct OtherConditionReview: Codable {
    let name: String
    let mappedCategory: String
    let includedInRiskScore: Bool
    let specialistRecommendation: String
    let clinicalNote: String
}

// MARK: - Bundle Models
struct BundleResponse: Codable {
    let personal: PersonalData
    let lifestyle: LifestyleData
    let familyHistory: FamilyHistoryData
    
    struct PersonalData: Codable {
        let fullName: String
        let age: Int?
        let gender: String?
        let bloodType: String?
        let phone: String?
        let email: String
    }
    
    struct LifestyleData: Codable {
        let activity: String?
        let diet: String?
        let smoking: String?
        let highSalt: Bool?
    }
    
    struct FamilyHistoryData: Codable {
        let myself: [String]?
        let father: [String]
        let mother: [String]
        let grandparents: [String]
        let siblings: [String]
        let otherConditions: [String]?
    }
}

// MARK: - Category Mapping Helper
struct CategoryMapper {
    static func getMappedName(for backendCategory: String) -> String {
        switch backendCategory.lowercased() {
        case "cardiac", "cardiovascular": return "Cardiovascular Diseases"
        case "metabolic", "metabolic_endocrine": return "Metabolic & Endocrine"
        case "neural", "neurological": return "Neurological Disorders"
        case "oncology": return "Oncology (Cancers)"
        case "respiratory", "blood", "blood_respiratory": return "Blood & Respiratory"
        default: return backendCategory
        }
    }
}
