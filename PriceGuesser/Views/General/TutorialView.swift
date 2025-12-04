import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Header
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("brandPrimary"))

                    Text("tutorial.title".localized)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                // Steps
                VStack(spacing: 24) {
                    TutorialStepCard(
                        icon: "1.circle.fill",
                        title: "tutorial.step1.title".localized,
                        description: "tutorial.step1.description".localized,
                        color: Color("brandPrimary")
                    )

                    TutorialStepCard(
                        icon: "2.circle.fill",
                        title: "tutorial.step2.title".localized,
                        description: "tutorial.step2.description".localized,
                        color: Color("brandSecondary")
                    )

                    TutorialStepCard(
                        icon: "3.circle.fill",
                        title: "tutorial.step3.title".localized,
                        description: "tutorial.step3.description".localized,
                        color: Color("AccentColor")
                    )

                    TutorialStepCard(
                        icon: "4.circle.fill",
                        title: "tutorial.step4.title".localized,
                        description: "tutorial.step4.description".localized,
                        color: Color("brandPrimary")
                    )

                    TutorialStepCard(
                        icon: "trophy.fill",
                        title: "tutorial.scoring.title".localized,
                        description: "tutorial.scoring.description".localized,
                        color: Color("AccentColor")
                    )

                    TutorialStepCard(
                        icon: "star.fill",
                        title: "tutorial.achievements.title".localized,
                        description: "tutorial.achievements.description".localized,
                        color: Color("brandSecondary")
                    )
                }
                .padding(.horizontal, 20)

                // Close Button
                Button {
                    HapticManager.impact(style: .light)
                    dismiss()
                } label: {
                    Text("tutorial.close".localized)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color("brandPrimary"))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .background(Color("backgroundColor"))
    }
}

struct TutorialStepCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cardBackground"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#if DEBUG
#Preview {
    TutorialView()
}
#endif
