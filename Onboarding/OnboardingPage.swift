import SwiftUI
import UIKit

struct OnboardingPage: View {

    let imageName: String
    let title: String
    let subtitle: String
    let index: Int
    let total: Int
    let isLast: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // iOS-Style Image Container (Full Width)
            let imageSize = UIScreen.main.bounds.width - 48
            
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.appSecondaryBackground) // Use secondary BG for card look
                    .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            .frame(width: imageSize, height: imageSize) // Maximize size
            .padding(.top, 10)
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.appText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 24)
            
            Text(subtitle)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.appSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineLimit(3)
                .minimumScaleFactor(0.9)
            
            Spacer()
            
            // Dots Indicator
            HStack(spacing: 8) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i == index ? Color.appTint : Color.gray.opacity(0.3))
                        .frame(width: i == index ? 10 : 8, height: i == index ? 10 : 8)
                        .animation(.spring(), value: index)
                }
            }
            .padding(.bottom, 10)
            
            Button(action: onNext) {
                Text(isLast ? "Get Started" : "Next")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.appTint)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

struct OnboardingPage_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPage(
            imageName: "onboarding1",
            title: "Understand Your Genetic Future",
            subtitle: "Use AI to assess potential health risks based on family history and lifestyle.",
            index: 0,
            total: 3,
            isLast: false,
            onNext: {}
        )
    }
}
