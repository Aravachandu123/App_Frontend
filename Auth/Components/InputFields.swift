import SwiftUI

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundColor(.appText)
                    .font(.system(size: 16, weight: .medium))
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appSecondaryBackground)
                    
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.appSecondaryText)
                            .padding(.horizontal, 16)
                            .font(.system(size: 16))
                    }
                    
                    TextField("", text: $text)
                        .foregroundColor(.appText)
                    .padding(.horizontal, 16)
                    .font(.system(size: 16))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .frame(height: 56)
        }
    }
}

struct SecureInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.appText)
                .font(.system(size: 16, weight: .medium))
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSecondaryBackground)
                
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.appSecondaryText)
                        .padding(.horizontal, 16)
                        .font(.system(size: 16))
                }
                
                HStack {
                    if isVisible {
                        TextField("", text: $text)
                            .foregroundColor(.appText)
                            .font(.system(size: 16))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("", text: $text)
                            .foregroundColor(.appText)
                            .font(.system(size: 16))
                    }
                    
                    Button(action: { isVisible.toggle() }) {
                        Image(systemName: isVisible ? "eye" : "eye.slash")
                            .foregroundColor(.appSecondaryText)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 56)
        }
    }
}
