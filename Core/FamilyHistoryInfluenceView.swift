//
//  FamilyHistoryInfluenceView.swift
//  GenCare Assist1
//
//  Created by SAIL on 20/02/26.
//

import SwiftUI

struct FamilyHistoryInfluenceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var familyHealthVM: FamilyHealthViewModel
    
    // Mapping relations to icons and colors for consistency
    let memberStyle: [String: (icon: String, color: Color)] = [
        "Myself": ("person.fill", .purple),
        "Father": ("person.bust.fill", .blue),
        "Mother": ("person.bust.fill", .pink),
        "Grandparents": ("person.2.fill", .orange),
        "Siblings": ("person.2.wave.2.fill", .green)
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Navigation Bar)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.appText)
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text("Family History Influence")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Intro Text
                        Text("Explore how your family's health history impacts your genetic risk assessment. Each family member's health conditions contribute to your overall risk profile.")
                            .font(.body)
                            .foregroundColor(.appText)
                            .lineSpacing(4)
                            .padding(.horizontal)
                        
                        // Dynamic List of Influences
                        VStack(spacing: 16) {
                            let relations = ["Mother", "Father", "Grandparents", "Siblings"]
                            
                            // Check if there are any conditions to show
                            let hasAnyConditions = relations.contains { relation in
                                let conditions = Array(familyHealthVM.conditionsByMember[relation, default: []]).filter { $0 != "None" }
                                return !conditions.isEmpty
                            }
                            
                            if hasAnyConditions {
                                ForEach(relations, id: \.self) { relation in
                                    let conditions = Array(familyHealthVM.conditionsByMember[relation, default: []]).filter { $0 != "None" }.sorted()
                                    
                                    if !conditions.isEmpty {
                                        FamilyInfluenceCardView(
                                            relation: relation,
                                            icon: memberStyle[relation]?.icon ?? "person.fill",
                                            color: memberStyle[relation]?.color ?? .blue,
                                            conditions: conditions
                                        )
                                    }
                                }
                            } else {
                                // Empty state if no relations have conditions (other than "None")
                                VStack(spacing: 12) {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color.green.opacity(0.8))
                                    Text("No significant family history recorded.")
                                        .font(.headline)
                                        .foregroundColor(.appText)
                                        .multilineTextAlignment(.center)
                                    Text("Your current family profile does not indicate inherited severe conditions.")
                                        .font(.subheadline)
                                        .foregroundColor(.appSecondaryText)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.appSecondaryBackground)
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct FamilyInfluenceCardView: View {
    let relation: String
    let icon: String
    let color: Color
    let conditions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(relation)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.appText)
                    Text("Inherited Risk Factors")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.appSecondaryText)
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.appSecondaryText.opacity(0.2))
            
            // Conditions List
            VStack(alignment: .leading, spacing: 12) {
                ForEach(conditions, id: \.self) { condition in
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(color)
                        
                        Text(condition)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color.appSecondaryBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    FamilyHistoryInfluenceView()
        .environmentObject(FamilyHealthViewModel())
}
