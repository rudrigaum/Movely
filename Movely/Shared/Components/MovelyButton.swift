//
//  MovelyButton.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/03/26.
//

import SwiftUI

// MARK: - Button Variant
public enum MovelyButtonVariant {
    case primary
    case secondary
    case ghost
    case destructive
}

// MARK: - Button Size
public enum MovelyButtonSize {
    case regular
    case small

    var height: CGFloat {
        switch self {
        case .regular: return .movely.buttonHeight
        case .small: return .movely.buttonHeightSmall
        }
    }

    var font: Font {
        switch self {
        case .regular: return .movely.button
        case .small: return .movely.subheadline
        }
    }
}

// MARK: - MovelyButton
public struct MovelyButton: View {

    // MARK: - Properties
    private let title: String
    private let variant: MovelyButtonVariant
    private let size: MovelyButtonSize
    private let isLoading: Bool
    private let isFullWidth: Bool
    private let action: () -> Void

    // MARK: - Init
    public init(
        _ title: String,
        variant: MovelyButtonVariant = .primary,
        size: MovelyButtonSize = .regular,
        isLoading: Bool = false,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    Text(title)
                        .font(size.font)
                        .foregroundStyle(foregroundColor)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, isFullWidth ? 0 : .movely.buttonPaddingHorizontal)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .movely.radiusFull))
            .overlay(
                RoundedRectangle(cornerRadius: .movely.radiusFull)
                    .strokeBorder(borderColor, lineWidth: variant == .secondary ? 1.5 : 0)
            )
        }
        .disabled(isLoading)
        .buttonStyle(MovelyPressButtonStyle())
    }

    // MARK: - Computed Colors
    private var backgroundColor: Color {
        switch variant {
        case .primary: return .movelyPrimary
        case .secondary: return .clear
        case .ghost: return .clear
        case .destructive: return .movelyError
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: return .white
        case .secondary: return .movelyPrimary
        case .ghost: return .movelyPrimary
        case .destructive: return .white
        }
    }

    private var borderColor: Color {
        switch variant {
        case .secondary: return .movelyPrimary
        default: return .clear
        }
    }
}

// MARK: - Press Button Style
private struct MovelyPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Buttons - Light") {
    MovelyButtonPreview()
        .preferredColorScheme(.light)
}

#Preview("Buttons - Dark") {
    MovelyButtonPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Preview View
private struct MovelyButtonPreview: View {
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: .movely.large) {

                buttonSection(title: "Primary") {
                    MovelyButton("Get Started") {}
                    MovelyButton("Get Started", size: .small, isFullWidth: false) {}
                }

                buttonSection(title: "Secondary") {
                    MovelyButton("Create Account", variant: .secondary) {}
                    MovelyButton("Create Account", variant: .secondary, size: .small, isFullWidth: false) {}
                }

                buttonSection(title: "Ghost") {
                    MovelyButton("Learn More", variant: .ghost) {}
                    MovelyButton("Learn More", variant: .ghost, size: .small, isFullWidth: false) {}
                }

                buttonSection(title: "Destructive") {
                    MovelyButton("Delete Account", variant: .destructive) {}
                    MovelyButton("Delete", variant: .destructive, size: .small, isFullWidth: false) {}
                }

                buttonSection(title: "Loading State") {
                    MovelyButton("Loading...", isLoading: true) {}
                    MovelyButton(
                        isLoading ? "Loading..." : "Tap to Load",
                        isLoading: isLoading
                    ) {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
                }
            }
            .padding(.movely.small)
        }
        .background(.movelyBackground)
    }

    private func buttonSection(
        title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: .movely.tiny) {
            Text(title.uppercased())
                .font(.movely.caption1)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextSecondary)
            Divider()
            content()
        }
    }
}
