import SwiftUI

struct SupportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    // Theme Colors
    let primaryBlue = Color.blue // Using standard blue to match design, or app theme if available
    
    var body: some View {
        NavigationView { // Ensure navigation context if needed, though usually pushed
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    
// Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search FAQs", text: $searchText)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Popular Topics Header
                    Text("Popular Topics")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Topic 1
                            SupportTopicRow(
                                category: "Genetic Risk 101",
                                title: "Understanding Your Genetic Risk",
                                description: "Learn the basics of genetic risk assessment and how it can impact your health.",
                                icon: "leaf",
                                iconColor: .green
                            )
                            
                            // Topic 2
                            SupportTopicRow(
                                category: "Privacy & Security",
                                title: "Your Data, Protected",
                                description: "We prioritize your privacy and security. Learn about our data protection measures.",
                                icon: "lock.shield",
                                iconColor: .red
                            )
                            
                            // Topic 3
                            SupportTopicRow(
                                category: "Interpreting Results",
                                title: "Decoding Your Genetic Insights",
                                description: "Understand your genetic risk assessment results and what they mean for your health.",
                                icon: "leaf.arrow.triangle.circle.path", // customizable
                                iconColor: .orange
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Contact Us Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Us")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                // Chat Action
                            }) {
                                Text("Chat")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(primaryBlue)
                                    .cornerRadius(16)
                            }
                            
                            Button(action: {
                                // Email Action
                            }) {
                                Text("Email Support")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(primaryBlue)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitle("Help & Support", displayMode: .inline)
            // If pushed from ProfileView, drag gesture/back button works automatically
        }
        .navigationBarBackButtonHidden(false)
    }
}

struct SupportTopicRow: View {
    let category: String
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.caption)
                    .foregroundColor(.secondary) // Adaptive gray
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary) // Adaptive white/black
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary) // Adaptive gray
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Icon Box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(iconColor)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SupportView()
}