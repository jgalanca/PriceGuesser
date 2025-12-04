import SwiftUI

struct AccessibilityConfig {
    static func configureGlobalAccessibility() {
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }

    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    static func screenChanged(to element: Any?) {
        UIAccessibility.post(notification: .screenChanged, argument: element)
    }

    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }

    static var isBoldTextEnabled: Bool {
        UIAccessibility.isBoldTextEnabled
    }

    static var prefersCrossFadeTransitions: Bool {
        UIAccessibility.prefersCrossFadeTransitions
    }

    static func layoutChanged(focusOn element: Any? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }
}

struct AccessibleCard<Content: View>: View {
    let content: Content
    let label: String
    let hint: String?

    init(
        label: String,
        hint: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.label = label
        self.hint = hint
    }

    var body: some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
    }
}

extension View {
    func accessibleCard(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .modifier(OptionalAccessibilityHint(hint: hint))
    }
}

private struct OptionalAccessibilityHint: ViewModifier {
    let hint: String?

    func body(content: Content) -> some View {
        if let hint = hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }
}

struct DynamicTypeScaling: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    let minScaleFactor: CGFloat

    init(minScaleFactor: CGFloat = 0.7) {
        self.minScaleFactor = minScaleFactor
    }

    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(minScaleFactor)
            .lineLimit(sizeCategory.isAccessibilityCategory ? nil : 1)
    }
}

extension View {
    func dynamicTypeScaling(minScaleFactor: CGFloat = 0.7) -> some View {
        modifier(DynamicTypeScaling(minScaleFactor: minScaleFactor))
    }

    func accessibleButton(label: String, hint: String? = nil, role: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .modifier(OptionalAccessibilityHint(hint: hint))
    }
}
