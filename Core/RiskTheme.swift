import SwiftUI

struct RiskTheme {
    static func iconForDomain(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("cardiac") || lower.contains("heart") { return "heart.fill" }
        if lower.contains("neural") || lower.contains("neurological") || lower.contains("nervous") { return "brain.head.profile" }
        if lower.contains("metabolic") || lower.contains("endocrine") { return "bolt.fill" }
        if lower.contains("oncology") || lower.contains("cancer") { return "cross.case.fill" }
        if lower.contains("blood") || lower.contains("respiratory") || lower.contains("lung") { return "lungs.fill" }
        return "waveform.path.ecg" // Default fallback
    }
    
    static func colorForDomain(_ name: String) -> Color {
        let lower = name.lowercased()
        // Soft versions of the colors using opacity to achieve a pastel/soft look on backgrounds
        if lower.contains("cardiac") || lower.contains("heart") { return Color.red.opacity(0.8) }
        if lower.contains("neural") || lower.contains("neurological") || lower.contains("nervous") { return Color.purple.opacity(0.8) }
        if lower.contains("metabolic") || lower.contains("endocrine") { return Color.orange.opacity(0.8) }
        if lower.contains("oncology") || lower.contains("cancer") { return Color.green.opacity(0.8) }
        if lower.contains("blood") || lower.contains("respiratory") || lower.contains("lung") { return Color.blue.opacity(0.8) }
        return Color.blue.opacity(0.8) // Default fallback
    }
    
    static func descriptionForDomain(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("cardiac") || lower.contains("heart") { return "Heart & circulation" }
        if lower.contains("neural") || lower.contains("neurological") || lower.contains("nervous") { return "Brain & nervous system" }
        if lower.contains("metabolic") || lower.contains("endocrine") { return "Energy, diabetes, hormones" }
        if lower.contains("oncology") || lower.contains("cancer") { return "Cancer & cell growth" }
        if lower.contains("blood") || lower.contains("respiratory") || lower.contains("lung") { return "Blood & lungs" }
        return "Associated conditions and risk factors." // Default
    }
    
    static func iconForRiskLevel(_ level: String) -> String {
        let lower = level.lowercased()
        if lower.contains("very high") { return "exclamationmark.octagon.fill" }
        if lower.contains("high") { return "exclamationmark.triangle.fill" }
        if lower.contains("mod") { return "exclamationmark.circle.fill" }
        if lower.contains("low") { return "checkmark.circle.fill" }
        return "info.circle.fill"
    }
    
    static func colorForRiskLevel(_ level: String) -> Color {
        let lower = level.lowercased()
        if lower.contains("very high") { return .purple }
        if lower.contains("high") { return .red }
        if lower.contains("mod") { return .orange }
        if lower.contains("low") { return .green }
        return .blue // Default fallback
    }
}
