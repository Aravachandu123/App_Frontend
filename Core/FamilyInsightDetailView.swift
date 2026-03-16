import SwiftUI

struct FamilyInsightDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let insightTitle: String
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var viewModel: FamilyHealthViewModel
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            // Minimal tech-grid or molecular background
            VStack {
                Circle()
                    .fill(Color.purple.opacity(0.05))
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .offset(x: -150, y: -200)
                Spacer()
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 48) {
                    
                    // MARK: - Page Title & Context
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GENETIC INHERITANCE MAP")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.appTint)
                            .tracking(3)
                        
                        Text("Family History Influence")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.appText)
                        
                        Text(insightTitle)
                            .font(.system(size: 15))
                            .foregroundColor(.appSecondaryText)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    
                    // MARK: - Influence Flow List
                    VStack(spacing: 56) {
                        ForEach(["Father", "Mother", "Grandparents", "Siblings"], id: \.self) { member in
                            InfluenceFlowSection(
                                relative: member,
                                conditions: Array(viewModel.conditionsByMember[member, default: []]).sorted(),
                                delay: influenceDelay(for: member)
                            )
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
    
    private func influenceDelay(for member: String) -> Double {
        switch member {
        case "Father": return 0.2
        case "Mother": return 0.4
        case "Grandparents": return 0.6
        case "Siblings": return 0.8
        default: return 0
        }
    }
}

// MARK: - Influence Flow Components

struct InfluenceFlowSection: View {
    let relative: String
    let conditions: [String]
    let delay: Double
    
    @State private var showLine = false
    
    private var hasConditions: Bool {
        !conditions.isEmpty && conditions.first != "None"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // 1. The Influence Header (Relative)
            HStack(alignment: .top, spacing: 20) {
                // Relative Node
                ZStack {
                    Circle()
                        .fill(memberColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: memberIcon)
                        .font(.title3.bold())
                        .foregroundColor(memberColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(relative)
                        .font(.headline.bold())
                        .foregroundColor(.appText)
                    
                    Text(inheritanceType)
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.appSecondaryText.opacity(0.6))
                        .tracking(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // 2. The Flow (Visualizing "Getting it from them")
            HStack(alignment: .top, spacing: 0) {
                // Vertical Line Segment
                VStack(spacing: 0) {
                    Circle()
                        .fill(memberColor)
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [memberColor, .appTint.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 2)
                        .frame(height: hasConditions ? CGFloat(conditions.count * 40) : 60)
                        .opacity(showLine ? 1 : 0)
                }
                .padding(.leading, 48)
                
                // 3. The Condition List ("Passed Traits")
                VStack(alignment: .leading, spacing: 16) {
                    if hasConditions {
                        ForEach(conditions.filter { $0 != "None" }, id: \.self) { condition in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("INFLUENCED TRAIT")
                                        .font(.system(size: 8, weight: .black))
                                        .foregroundColor(memberColor)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(memberColor.opacity(0.1))
                                        .cornerRadius(4)
                                    Spacer()
                                }
                                
                                Text(condition)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.appText)
                            }
                            .padding(.leading, 20)
                        }
                    } else {
                        Text("No direct risk transmission detected.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appSecondaryText)
                            .italic()
                            .padding(.leading, 20)
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(delay)) {
                showLine = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private var memberIcon: String {
        switch relative {
        case "Father", "Mother": return "person.bust.fill"
        case "Grandparents": return "person.2.fill"
        case "Siblings": return "person.2.wave.2.fill"
        default: return "person.fill"
        }
    }
    
    private var memberColor: Color {
        switch relative {
        case "Father": return .blue
        case "Mother": return .pink
        case "Grandparents": return .orange
        case "Siblings": return .green
        default: return .appTint
        }
    }
    
    private var inheritanceType: String {
        switch relative {
        case "Father": return "PATERNAL LINEAGE"
        case "Mother": return "MATERNAL LINEAGE"
        case "Grandparents": return "ANCESTRAL ROOTS"
        case "Siblings": return "SHARED VARIANCE"
        default: return "FAMILY INFLUENCE"
        }
    }
}

#Preview {
    NavigationView {
        FamilyInsightDetailView(
            insightTitle: "Analyzing how conditions are influenced by specific relatives in your lineage."
        )
        .environmentObject(LanguageManager())
        .environmentObject(FamilyHealthViewModel())
    }
}
