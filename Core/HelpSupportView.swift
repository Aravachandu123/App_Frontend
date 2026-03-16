import SwiftUI
import UIKit

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                // Header removed for standard navigation

                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.appSecondaryText)
                            
                            TextField("Search FAQs", text: $searchText)
                                .foregroundColor(.appText)
                                .placeholder(when: searchText.isEmpty) {
                                    Text("Search FAQs").foregroundColor(.appSecondaryText)
                                }
                        }
                        .padding()
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(12)
                        
                        // Popular Topics
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Popular Topics")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appText)
                            
                            TopicCard(
                                category: "Genetic Risk 101",
                                title: "Understanding Your Genetic Risk",
                                description: "Learn the basics of genetic risk assessment and how it can impact your health.",
                                icon: "leaf",
                                color: Color(UIColor.systemGreen) // Use system colors for adaptability or keep branded
                            )
                            
                            TopicCard(
                                category: "Privacy & Security",
                                title: "Your Data, Protected",
                                description: "We prioritize your privacy and security. Learn about our data protection measures.",
                                icon: "lock.shield",
                                color: Color(UIColor.systemRed)
                            )
                            
                            TopicCard(
                                category: "Interpreting Results",
                                title: "Decoding Your Genetic Insights",
                                description: "Understand your genetic risk assessment results and what they mean for your health.",
                                icon: "leaf",
                                color: Color(UIColor.systemOrange)
                            )
                        }
                        
                        // Contact Us
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contact Us")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appText)
                            
                            Button(action: {
                                print("Chat tapped")
                            }) {
                                Text("Chat")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white) // Button text usually white on blue
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.appTint)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.scaleEffect)
                            
                            Button(action: {
                                print("Email Support tapped")
                            }) {
                                Text("Email Support")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.appTint)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.scaleEffect)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
        .standardBackButton()
    }
}

struct TopicCard: View {
    let category: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(category)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appSecondaryText)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appText)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.appSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            .padding(.trailing, 16)
            
            Spacer(minLength: 0)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSecondaryBackground)
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(color)
            }
        }
        .padding(16)
    }
}



#Preview {
    NavigationStack {
        HelpSupportView()
    }
}
