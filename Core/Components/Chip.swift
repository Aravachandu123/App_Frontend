import SwiftUI

struct Chip: View {
    let text: String
    var icon: String? = nil
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    // Initializer for Optional String Binding (LifestyleView)
    init(text: String, icon: String? = nil, color: Color = .blue, selectedOption: Binding<String?>) {
        self.text = text
        self.icon = icon
        self.color = color
        self.isSelected = selectedOption.wrappedValue == text
        self.action = {
            selectedOption.wrappedValue = text
        }
    }
    
    // Initializer for Non-Optional String Binding (EditLifestyleView)
    init(text: String, icon: String? = nil, color: Color = .blue, selectedOption: Binding<String>) {
        self.text = text
        self.icon = icon
        self.color = color
        self.isSelected = selectedOption.wrappedValue == text
        self.action = {
            selectedOption.wrappedValue = text
        }
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(isSelected ? .white : color)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minWidth: 100)
        .background(
             RoundedRectangle(cornerRadius: 12)
                 .fill(isSelected ? color : color.opacity(0.15))
                 .overlay(
                     RoundedRectangle(cornerRadius: 12)
                         .stroke(isSelected ? color : color.opacity(0.5), lineWidth: 1.5)
                 )
         )
        .onTapGesture {
            action()
        }
    }
}
