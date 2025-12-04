import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isEnabled: Bool = true
    var accessibilityLabel: String?
    var accessibilityHint: String?

    init(
        _ title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }

    var body: some View {
        Button(
            action: {
                HapticManager.impact(style: .medium)
                action()
            },
            label: {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.title3)
                    }
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isEnabled ? Color("brandPrimary") : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: isEnabled ? Color("brandPrimary").opacity(0.4) : Color.clear, radius: 15, x: 0, y: 8)
            }
        )
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel ?? title)
        .if(accessibilityHint != nil) { view in
            view.accessibilityHint(accessibilityHint!)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    var accessibilityLabel: String?
    var accessibilityHint: String?

    init(
        _ title: String,
        icon: String? = nil,
        color: Color = Color("brandPrimary"),
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }

    var body: some View {
        Button(
            action: {
                HapticManager.impact(style: .light)
                action()
            },
            label: {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.title3)
                    }
                    Text(title)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color("cardBackground"))
                .foregroundColor(color)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color, lineWidth: 2)
                )
            }
        )
        .accessibilityLabel(accessibilityLabel ?? title)
        .if(accessibilityHint != nil) { view in
            view.accessibilityHint(accessibilityHint!)
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color("cardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor").ignoresSafeArea())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color("brandPrimary").opacity(0.6))

            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle = actionTitle, let action = action {
                Button(
                    action: {
                        HapticManager.impact(style: .light)
                        action()
                    },
                    label: {
                        Text(actionTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color("brandPrimary"))
                            .cornerRadius(12)
                    }
                )
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
