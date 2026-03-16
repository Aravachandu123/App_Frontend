import Foundation

final class RiskEngine {
    static let shared = RiskEngine()
    
    // MARK: - Constants for Domains
    private let domainConfigs: [String: (name: String, icon: String, accent: String)] = [
        "cardiovascular": ("Cardiac", "heart.fill", "softRed"),
        "neurological": ("Neural", "brain.head.profile", "softPurple"),
        "metabolic_endocrine": ("Metabolic", "bolt.fill", "softOrange"),
        "oncology": ("Oncology", "cross.case.fill", "softGreen"),
        "blood_respiratory": ("Blood & Respiratory", "lungs.fill", "softBlue")
    ]
    
    // MARK: - Main Calculation
    func calculateRisk(from input: RiskInput) -> RiskResult {
        // Rule 8: If the user selected nothing in all domains, everything is empty/Unknown.
        // Modified: We removed the strict check so that Family History and Lifestyle can still produce risk results
        // even if personal conditions are empty.

        
        let domains = computeDomains(from: input)
        let overall = computeOverallRisk(from: domains, input: input)
        let topRiskAreas = computeTopRiskAreas(from: domains)
        let keyContributors = computeKeyContributors(from: input, domains: domains)
        let familyInfluence = computeFamilyInfluence(from: input)
        let recommendations = computeRecommendations(from: domains, lifestyle: input.lifestyle)
        let history = computeHistory(from: input) // Mocked based on current state for now
        
        return RiskResult(
            overall: overall,
            domains: domains,
            topRiskAreas: topRiskAreas,
            keyContributors: keyContributors,
            familyInfluence: familyInfluence,
            recommendations: recommendations,
            history: history
        )
    }
    
    // MARK: - Helpers
    private func emptyRiskResult() -> RiskResult {
        return RiskResult(
            overall: RiskOverall(riskLevel: "Unknown", riskPercent: 0, healthScore: 100),
            domains: [],
            topRiskAreas: [],
            keyContributors: [],
            familyInfluence: [],
            recommendations: RiskRecommendationsResult(highPriority: [], moderatePriority: [], lifestyleAdvice: []),
            history: []
        )
    }
    
    private func computeDomains(from input: RiskInput) -> [RiskDomain] {
        var resultDomains: [RiskDomain] = []
        
        // Merge personal and family conditions for domain computation
        var allDomainConditions: [String: [String]] = [:]
        
        // 1. Add personal conditions
        for (domainKey, conditions) in input.selectedConditionsByDomain {
            if !conditions.isEmpty {
                allDomainConditions[domainKey, default: []].append(contentsOf: conditions)
            }
        }
        
        // 2. Add family conditions based on keyword mapping or basic heuristics
        // Since we don't have a perfect mapper in the engine without backend categorizer, 
        // we'll try to map family conditions to domains.
        let familyConds = input.familyHistorySelected.values.flatMap { $0 }
        for cond in familyConds {
            let lowerCond = cond.lowercased()
            if lowerCond.contains("heart") || lowerCond.contains("cardio") || lowerCond.contains("bp") || lowerCond.contains("hypertension") {
                allDomainConditions["cardiovascular", default: []].append(cond)
            } else if lowerCond.contains("diabetes") || lowerCond.contains("thyroid") || lowerCond.contains("pcos") {
                allDomainConditions["metabolic_endocrine", default: []].append(cond)
            } else if lowerCond.contains("cancer") || lowerCond.contains("tumor") {
                allDomainConditions["oncology", default: []].append(cond)
            } else if lowerCond.contains("alzheimer") || lowerCond.contains("parkinson") || lowerCond.contains("neuro") || lowerCond.contains("dementia") {
                allDomainConditions["neurological", default: []].append(cond)
            } else if lowerCond.contains("anemia") || lowerCond.contains("sickle") || lowerCond.contains("asthma") || lowerCond.contains("respiratory") {
                allDomainConditions["blood_respiratory", default: []].append(cond)
            }
        }
        
        for (domainKey, conditions) in allDomainConditions {
            // Rule 1: If an array has 0 selected conditions, DO NOT include that domain
            if conditions.isEmpty { continue }
            
            let uniqueConditions = Array(Set(conditions)).sorted()
            let config = domainConfigs[domainKey] ?? (name: domainKey.capitalized, icon: "cross.case.fill", accent: "softGray")
            
            // Basic mock logic - 10% per condition, max 90%
            let riskPercent = min(uniqueConditions.count * 15 + 20, 95)
            let riskLevel = determineRiskLevel(percent: riskPercent)
            
            let domain = RiskDomain(
                id: domainKey,
                name: config.name,
                icon: config.icon,
                accent: config.accent,
                riskPercent: riskPercent,
                riskLevel: riskLevel,
                selectedConditions: uniqueConditions,
                whyThisRisk: "Based on \(uniqueConditions.count) reported conditions.",
                tips: generateDomainTips(for: domainKey, conditions: uniqueConditions)
            )
            resultDomains.append(domain)
        }
        
        return resultDomains
    }
    
    private func computeTopRiskAreas(from domains: [RiskDomain]) -> [RiskDomain] {
        // Rule 2: Top 2-3 domains by riskPercent ONLY among selected domains.
        let sorted = domains.sorted { $0.riskPercent > $1.riskPercent }
        return Array(sorted.prefix(3))
    }
    
    private func computeOverallRisk(from domains: [RiskDomain], input: RiskInput) -> RiskOverall {
        guard !domains.isEmpty else {
            return RiskOverall(riskLevel: "Low Risk", riskPercent: 0, healthScore: 100)
        }
        
        let maxDomainRisk = domains.map { $0.riskPercent }.max() ?? 0
        
        let overallPercent = maxDomainRisk
        let healthScore = 100 - overallPercent
        
        return RiskOverall(
            riskLevel: determineRiskLevel(percent: overallPercent),
            riskPercent: overallPercent,
            healthScore: healthScore
        )
    }
    
    private func computeFamilyInfluence(from input: RiskInput) -> [FamilyMemberInfluence] {
        var memberPoints: [(relation: String, conditions: [String], points: Int)] = []
        var totalPoints = 0
        
        // Rule 5: Show members ONLY if user selected conditions. If array empty, DO NOT show.
        for (relation, conditions) in input.familyHistorySelected {
            if conditions.isEmpty { continue }
            
            // Assign points (e.g., 10 points per condition)
            let points = conditions.count * 10
            memberPoints.append((relation, conditions, points))
            totalPoints += points
        }
        
        if totalPoints == 0 { return [] } // No members with conditions
        
        // Compute exact percentages and floor values for normalization
        var exactPercents: [(relation: String, conditions: [String], exact: Double, floorVal: Int)] = []
        var sumFloor = 0
        
        for m in memberPoints {
            let exact = (Double(m.points) / Double(totalPoints)) * 100.0
            let floorVal = Int(exact)
            exactPercents.append((m.relation, m.conditions, exact, floorVal))
            sumFloor += floorVal
        }
        
        var remainderToDistribute = 100 - sumFloor
        
        // Sort by the largest fractional remainder to distribute the remaining percentage points
        exactPercents.sort { ($0.exact - Double($0.floorVal)) > ($1.exact - Double($1.floorVal)) }
        
        var finalResults: [FamilyMemberInfluence] = []
        for i in 0..<exactPercents.count {
            var finalPercent = exactPercents[i].floorVal
            if remainderToDistribute > 0 {
                finalPercent += 1
                remainderToDistribute -= 1
            }
            finalResults.append(FamilyMemberInfluence(
                relation: exactPercents[i].relation.capitalized,
                conditions: exactPercents[i].conditions,
                influencePercent: finalPercent
            ))
        }
        
        // Sort the final output by largest influence
        return finalResults.sorted { $0.influencePercent > $1.influencePercent }
    }
    
    private func computeKeyContributors(from input: RiskInput, domains: [RiskDomain]) -> [RiskContributor] {
        var contributors: [RiskContributor] = []
        
        if !domains.isEmpty {
            contributors.append(RiskContributor(factor: "Reported Conditions", contributionPercent: 60))
        }
        
        let familyConds = input.familyHistorySelected.values.flatMap { $0 }
        if !familyConds.isEmpty {
            contributors.append(RiskContributor(factor: "Family History", contributionPercent: 30))
        }
        
        if input.lifestyle.smokingStatus == "yes" || input.lifestyle.dietType == "poor" {
            contributors.append(RiskContributor(factor: "Lifestyle Factors", contributionPercent: 10))
        }
        
        return contributors
    }
    
    private func computeRecommendations(from domains: [RiskDomain], lifestyle: RiskInput.LifestyleInput) -> RiskRecommendationsResult {
        var high: [String] = []
        var moderate: [String] = []
        var advice: [String] = []
        
        // Rule 6: Generate actions ONLY from selected conditions + computed domain risks.
        for domain in domains {
            if domain.riskPercent >= 60 {
                high.append("Consult a specialist regarding your \(domain.name) risk.")
            } else if domain.riskPercent >= 30 {
                moderate.append("Monitor factors related to \(domain.name) health.")
            }
        }
        
        // If lifestyle is good, lifestyleAdvice must be EMPTY
        let needsLifestyleAdvice = (lifestyle.activityLevel == "low") || (lifestyle.dietType == "poor") || (lifestyle.smokingStatus == "yes") || (lifestyle.highSalt == true)
        
        if needsLifestyleAdvice {
            if lifestyle.activityLevel == "low" { advice.append("Increase daily physical activity.") }
            if lifestyle.smokingStatus == "yes" { advice.append("Consider a smoking cessation program.") }
            if lifestyle.highSalt == true { advice.append("Reduce sodium intake to support heart health.") }
        }
        
        return RiskRecommendationsResult(highPriority: high, moderatePriority: moderate, lifestyleAdvice: advice)
    }
    
    private func computeHistory(from input: RiskInput) -> [RiskHistoryEntry] {
        // Mocking history based on current selection as per request parameters (no dates, consistent calc)
        // In a real scenario, this would load from persistence.
        return []
    }
    
    // MARK: - Utilities
    private func determineRiskLevel(percent: Int) -> String {
        if percent >= 60 { return "High Risk" }
        if percent >= 30 { return "Moderate Risk" }
        return "Low Risk"
    }
    
    private func generateDomainTips(for domainId: String, conditions: [String]) -> [String] {
        return ["Stay proactive with regular checkups.", "Discuss these specific conditions with your doctor."]
    }
}
