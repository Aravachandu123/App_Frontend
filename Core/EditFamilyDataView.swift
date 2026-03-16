import SwiftUI

struct EditFamilyDataView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: FamilyHealthViewModel
    
    @State private var selectedMemberItem: FamilyMemberItem? = nil
    
    // Available Categories
    let availableCategories = [
        ConditionCategory(name: "Cardiovascular Diseases", conditions: [
            "Coronary Artery Disease", "Hypertension", "Hypercholesterolemia (Familial Hypercholesterolemia)", "Cardiomyopathy (Hypertrophic cardiomyopathy)"
        ]),
        ConditionCategory(name: "Oncology (Cancers)", conditions: [
            "Breast Cancer (BRCA1/BRCA2)", "Ovarian Cancer", "Colorectal Cancer (Lynch syndrome)", "Prostate Cancer", "Pancreatic Cancer"
        ]),
        ConditionCategory(name: "Neurological Disorders", conditions: [
            "Alzheimer’s Disease", "Parkinson’s Disease", "Huntington’s Disease"
        ]),
        ConditionCategory(name: "Blood & Respiratory", conditions: [
            "Sickle Cell Anemia", "Thalassemia", "Hemophilia", "G6PD Deficiency", "Cystic Fibrosis", "Alpha-1 Antitrypsin Deficiency"
        ]),
        ConditionCategory(name: "Metabolic & Endocrine", conditions: [
            "Type 2 Diabetes Mellitus", "Thyroid Disorders (Autoimmune)", "PCOS"
        ])
    ]
    
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
                        
                        Text("Edit Family History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                        
                        Text("Tap 'Edit' on a family member card to update their medical conditions.")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    
                    // Family Members Grid/List
                    VStack(spacing: 16) {
                        EditableFamilyCard(
                            relation: "Myself",
                            icon: "person.fill",
                            color: .purple,
                            conditions: Array(viewModel.conditionsByMember["Myself", default: []]).sorted(),
                            onEdit: {
                                selectedMemberItem = FamilyMemberItem(id: "Myself")
                            }
                        )
                        
                        EditableFamilyCard(
                            relation: "Father",
                            icon: "person.bust.fill",
                            color: .blue,
                            conditions: Array(viewModel.conditionsByMember["Father", default: []]).sorted(),
                            onEdit: {
                                selectedMemberItem = FamilyMemberItem(id: "Father")
                            }
                        )
                        
                        EditableFamilyCard(
                            relation: "Mother",
                            icon: "person.bust.fill",
                            color: .pink,
                            conditions: Array(viewModel.conditionsByMember["Mother", default: []]).sorted(),
                            onEdit: {
                                selectedMemberItem = FamilyMemberItem(id: "Mother")
                            }
                        )
                        
                        EditableFamilyCard(
                            relation: "Grandparents",
                            icon: "person.2.fill",
                            color: .orange,
                            conditions: Array(viewModel.conditionsByMember["Grandparents", default: []]).sorted(),
                            onEdit: {
                                selectedMemberItem = FamilyMemberItem(id: "Grandparents")
                            }
                        )
                        
                        EditableFamilyCard(
                            relation: "Siblings",
                            icon: "person.2.wave.2.fill",
                            color: .green,
                            conditions: Array(viewModel.conditionsByMember["Siblings", default: []]).sorted(),
                            onEdit: {
                                selectedMemberItem = FamilyMemberItem(id: "Siblings")
                            }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Edit Family Data")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
        .sheet(item: $selectedMemberItem) { item in
            ConditionSelectionSheet(
                member: item.id,
                availableCategories: availableCategories,
                viewModel: viewModel
            )
        }
    }
}

struct FamilyMemberItem: Identifiable {
    let id: String
}

struct EditableFamilyCard: View {
    let relation: String
    let icon: String
    let color: Color
    let conditions: [String]
    let onEdit: () -> Void
    
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
                
                // Edit Button
                Button(action: onEdit) {
                    Text("Edit")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color)
                        .cornerRadius(20)
                }
            }
            
            Divider()
                .background(Color.appSecondaryText.opacity(0.2))
            
            // Conditions List
            if !conditions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(conditions, id: \.self) { condition in
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

// Reusing ConditionSelectionSheet from previous implementation (it was fine, or I can redefine it here if needed)
// Assuming it's already defined or visible. 
// Wait, ConditionSelectionSheet was defined in the same file `EditFamilyDataView.swift` previously.
// I must redefine it here if I am overwriting the file.

struct ConditionSelectionSheet: View {
    let member: String
    let availableCategories: [ConditionCategory]
    @ObservedObject var viewModel: FamilyHealthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availableCategories) { category in
                    Section(header: Text(category.name)) {
                        ForEach(category.conditions, id: \.self) { condition in
                            HStack {
                                Text(condition)
                                    .foregroundColor(.appText)
                                Spacer()
                                if viewModel.hasCondition(member: member, condition: condition) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if condition == "None" {
                                    if viewModel.hasCondition(member: member, condition: "None") {
                                        viewModel.toggleCondition(member: member, condition: "None")
                                    } else {
                                        // Clear all
                                        viewModel.conditionsByMember[member]?.removeAll()
                                        viewModel.toggleCondition(member: member, condition: "None")
                                    }
                                } else {
                                    if viewModel.hasCondition(member: member, condition: "None") {
                                        viewModel.toggleCondition(member: member, condition: "None")
                                    }
                                    viewModel.toggleCondition(member: member, condition: condition)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditFamilyDataView()
            .environmentObject(FamilyHealthViewModel())
    }
}