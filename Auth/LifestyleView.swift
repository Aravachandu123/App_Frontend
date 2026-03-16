import SwiftUI

struct LifestyleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFamilyHistory = false
    @State private var showAlert = false
    
    // Persistent Data
    @AppStorage("lifestyleActivity") private var selectedActivity = ""
    @AppStorage("lifestyleDiet") private var selectedDiet = ""
    @AppStorage("lifestyleSmoking") private var selectedSmoking = ""
    
    // Options
    private let activityOptions = ["Daily", "Regularly", "Moderately", "Never"]
    private let dietOptions = ["Balanced", "Vegetarian", "Vegan"]
    private let smokingOptions = ["Never", "Former", "Occasional", "Regular"]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            List {
                Section(header: Text("Physical Activity")) {
                    ForEach(activityOptions, id: \.self) { option in
                        SelectionRow(title: option, selectedOption: $selectedActivity)
                    }
                }
                
                Section(header: Text("Dietary Habits")) {
                    ForEach(dietOptions, id: \.self) { option in
                        SelectionRow(title: option, selectedOption: $selectedDiet)
                    }
                }
                
                Section(header: Text("Smoking Status")) {
                    ForEach(smokingOptions, id: \.self) { option in
                        SelectionRow(title: option, selectedOption: $selectedSmoking)
                    }
                }
                
                Section {
                    Button(action: {
                        if selectedActivity.isEmpty || selectedDiet.isEmpty || selectedSmoking.isEmpty {
                            showAlert = true
                            return
                        }
                        
                        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
                        let payload: [String: Any] = [
                            "activity_level": selectedActivity,
                            "diet_type": selectedDiet,
                            "smoking_status": selectedSmoking,
                            "high_salt": false
                        ]
                        
                        NetworkManager.shared.request(endpoint: .updateLifestyle(email: email, payload: payload)) { (result: Result<EmptyResponse, Error>) in
                            DispatchQueue.main.async {
                                if case .success = result {
                                    self.logLifestyleUpdate(email: email)
                                }
                                RiskService.shared.recalculateRisk(email: email) { _ in }
                            }
                        }
                        showFamilyHistory = true
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Lifestyle")
        .navigationBarTitleDisplayMode(.large)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Missing Information"),
                message: Text("Please select all lifestyle options before continuing."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationDestination(isPresented: $showFamilyHistory) {
            FamilyMedicalHistoryView()
        }
    }
    
    private func logLifestyleUpdate(email: String) {
        let payload: [String: Any] = [
            "email": email,
            "title": "Lifestyle Updated",
            "subtitle": "You have successfully updated your lifestyle profile.",
            "icon": "leaf.fill",
            "color": "#34C759"
        ]
        NetworkManager.shared.request(endpoint: .addLog(payload: payload)) { (result: Result<EmptyResponse, Error>) in }
    }
}

struct SelectionRow: View {
    let title: String
    @Binding var selectedOption: String
    
    var body: some View {
        Button(action: {
            selectedOption = title
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.appText)
                Spacer()
                if selectedOption == title {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    LifestyleView()
}