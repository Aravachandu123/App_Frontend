import Foundation

// MARK: - Input Models for Risk Engine
struct RiskInput {
    let selectedConditionsByDomain: [String: [String]]
    let familyHistorySelected: [String: [String]]
    let lifestyle: LifestyleInput
    let demographics: DemographicsInput
    
    struct LifestyleInput {
        let activityLevel: String?
        let dietType: String?
        let smokingStatus: String?
        let highSalt: Bool?
    }
    
    struct DemographicsInput {
        let age: Int?
        let gender: String?
        let bloodType: String?
    }
    
    var hasAnySelectedConditions: Bool {
        return selectedConditionsByDomain.values.contains { !$0.isEmpty }
    }
}

// MARK: - Output Models matching strict JSON requirements
struct RiskResult: Codable, Equatable {
    let overall: RiskOverall
    let domains: [RiskDomain]
    let topRiskAreas: [RiskDomain]
    let keyContributors: [RiskContributor]
    let familyInfluence: [FamilyMemberInfluence]
    let recommendations: RiskRecommendationsResult
    let history: [RiskHistoryEntry]
}

struct RiskOverall: Codable, Equatable {
    let riskLevel: String
    let riskPercent: Int
    let healthScore: Int
}

struct RiskDomain: Codable, Equatable {
    let id: String // "cardiac", "neural", "metabolic_endocrine", etc.
    let name: String // "Cardiac", "Neural", etc.
    let icon: String
    let accent: String
    let riskPercent: Int
    let riskLevel: String
    let selectedConditions: [String]
    let whyThisRisk: String
    let tips: [String]
}

struct RiskContributor: Codable, Equatable {
    let factor: String
    let contributionPercent: Int
}

struct FamilyMemberInfluence: Codable, Equatable {
    let relation: String
    let conditions: [String]
    let influencePercent: Int
}

struct RiskRecommendationsResult: Codable, Equatable {
    let highPriority: [String]
    let moderatePriority: [String]
    let lifestyleAdvice: [String]
}

struct RiskHistoryEntry: Codable, Equatable, Identifiable {
    let id: Int
    let overallRiskPercent: Int
    let overallRiskLevel: String
    let dominantCategory: String
    let riskBreakdown: [String: Int]?
    let responseJson: RiskResult?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case overallRiskPercent = "overall_risk_percent"
        case overallRiskLevel = "overall_risk_level"
        case dominantCategory = "dominant_category"
        case riskBreakdown = "risk_breakdown"
        case responseJson = "response_json"
        case createdAt = "created_at"
    }
}
