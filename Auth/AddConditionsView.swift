import SwiftUI

struct ConditionCategory: Identifiable {
    let id = UUID()
    let name: String
    let conditions: [String]
}

struct AddConditionsView: View {
    private let categories = [
        ConditionCategory(name: "No Known Conditions", conditions: [
            "None"
        ]),
        ConditionCategory(name: "Cardiovascular", conditions: [
            "Coronary Artery Disease",
            "Hypertension",
            "Hypercholesterolemia (Familial Hypercholesterolemia)",
            "Cardiomyopathy (Hypertrophic cardiomyopathy)"
        ]),
        ConditionCategory(name: "Oncology (Cancers)", conditions: [
            "Breast Cancer (BRCA1/BRCA2)",
            "Ovarian Cancer",
            "Colorectal Cancer (Lynch syndrome)",
            "Prostate Cancer",
            "Pancreatic Cancer"
        ]),
        ConditionCategory(name: "Neurological Disorders", conditions: [
            "Alzheimer’s Disease",
            "Parkinson’s Disease",
            "Huntington’s Disease"
        ]),
        ConditionCategory(name: "Blood & Respiratory", conditions: [
            "Sickle Cell Anemia",
            "Thalassemia",
            "Hemophilia",
            "G6PD Deficiency",
            "Cystic Fibrosis",
            "Alpha-1 Antitrypsin Deficiency"
        ]),
        ConditionCategory(name: "Metabolic & Endocrine", conditions: [
            "Type 2 Diabetes Mellitus",
            "Thyroid Disorders (Autoimmune)",
            "PCOS"
        ])
    ]

    @EnvironmentObject var viewModel: FamilyHealthViewModel
    let memberName: String

    @State private var otherConditionText = ""
    @Environment(\.dismiss) private var dismiss

    init(memberName: String) {
        self.memberName = memberName
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            List {
                ForEach(categories) { category in
                    Section(header: Text(category.name)) {
                        ForEach(category.conditions, id: \.self) { condition in
                            ConditionRow(
                                condition: condition,
                                isSelected: viewModel.conditionsByMember[memberName]?.contains(condition) ?? false
                            ) {
                                viewModel.toggleCondition(member: memberName, condition: condition)
                            }
                        }
                    }
                }
                
                Section(header: Text("Other Condition")) {
                    HStack {
                        TextField("Enter condition...", text: $otherConditionText)
                            .foregroundColor(.appText)
                        
                        Button(action: addOtherCondition) {
                            Text("Add")
                                .fontWeight(.medium)
                        }
                        .disabled(otherConditionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Add Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }


    private func addOtherCondition() {
        let trimmed = otherConditionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            if viewModel.conditionsByMember[memberName]?.contains("None") == true {
                viewModel.toggleCondition(member: memberName, condition: "None")
            }
            if viewModel.conditionsByMember[memberName]?.contains(trimmed) != true {
                viewModel.toggleCondition(member: memberName, condition: trimmed)
            }
            otherConditionText = ""
        }
    }
}

#Preview {
    NavigationStack {
        AddConditionsView(memberName: "Father")
            .environmentObject(FamilyHealthViewModel())
    }
}



struct ConditionRow: View {
    let condition: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: {
            onToggle()
        }) {
            HStack {
                Text(condition)
                    .foregroundColor(.appText)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    AddConditionsView(memberName: "Father")
        .environmentObject(FamilyHealthViewModel())
}