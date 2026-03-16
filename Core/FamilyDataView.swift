import SwiftUI

struct FamilyDataView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: FamilyHealthViewModel
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        
                        Text("Family History Data")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Text("View the recorded medical conditions for your family members.")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                    
                    // Family Members Grid/List
                    VStack(spacing: 16) {
                        ReadOnlyFamilyCard2(
                            relation: "Myself",
                            icon: "person.fill",
                            color: .purple,
                            conditions: Array(viewModel.conditionsByMember["Myself", default: []]).sorted()
                        )
                        
                        ReadOnlyFamilyCard2(
                            relation: "Father",
                            icon: "person.bust.fill",
                            color: .blue,
                            conditions: Array(viewModel.conditionsByMember["Father", default: []]).sorted()
                        )
                        
                        ReadOnlyFamilyCard2(
                            relation: "Mother",
                            icon: "person.bust.fill",
                            color: .pink,
                            conditions: Array(viewModel.conditionsByMember["Mother", default: []]).sorted()
                        )
                        
                        ReadOnlyFamilyCard2(
                            relation: "Grandparents",
                            icon: "person.2.fill",
                            color: .orange,
                            conditions: Array(viewModel.conditionsByMember["Grandparents", default: []]).sorted()
                        )
                        
                        ReadOnlyFamilyCard2(
                            relation: "Siblings",
                            icon: "person.2.wave.2.fill",
                            color: .green,
                            conditions: Array(viewModel.conditionsByMember["Siblings", default: []]).sorted()
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Family Data")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

struct ReadOnlyFamilyCard2: View {
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
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(relation)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
                
                Spacer()
            }
            
            Divider()
                .background(Color.appSecondaryText.opacity(0.2))
            
            // Conditions List
            if !conditions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(conditions.filter { $0 != "None" }, id: \.self) { condition in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(color)
                            
                            Text(condition)
                                .font(.subheadline)
                                .foregroundColor(.appText)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            } else {
                Text("No conditions recorded")
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.appSecondaryText)
            }
        }
        .padding(20)
        .background(Color.appSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        FamilyDataView()
            .environmentObject(FamilyHealthViewModel())
    }
}