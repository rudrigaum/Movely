//
//  MovelyCard.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/03/26.
//

import SwiftUI

// MARK: - Card Variant
public enum MovelyCardVariant {
    case elevated
    case outlined
    case filled
}

// MARK: - MovelyCard
public struct MovelyCard<Content: View>: View {

    // MARK: - Properties
    private let variant: MovelyCardVariant
    private let padding: CGFloat
    private let content: Content

    // MARK: - Init
    public init(
        variant: MovelyCardVariant = .elevated,
        padding: CGFloat = .movely.large,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.padding = padding
        self.content = content()
    }

    // MARK: - Body
    public var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .movely.radiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: .movely.radiusLarge)
                    .strokeBorder(borderColor, lineWidth: variant == .outlined ? 1.5 : 0)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }

    // MARK: - Computed Properties
    private var backgroundColor: Color {
        switch variant {
        case .elevated: return .movelyBackgroundElevated
        case .outlined: return .movelyBackgroundElevated
        case .filled: return .movelyBackgroundGrouped
        }
    }

    private var borderColor: Color {
        switch variant {
        case .outlined: return .movelyBorder
        default: return .clear
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .elevated: return Color.black.opacity(0.08)
        default: return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch variant {
        case .elevated: return 12
        default: return 0
        }
    }

    private var shadowY: CGFloat {
        switch variant {
        case .elevated: return 4
        default: return 0
        }
    }
}

// MARK: - Tappable Card
public struct MovelyTappableCard<Content: View>: View {

    // MARK: - Properties
    private let variant: MovelyCardVariant
    private let padding: CGFloat
    private let action: () -> Void
    private let content: Content

    // MARK: - Init
    public init(
        variant: MovelyCardVariant = .elevated,
        padding: CGFloat = .movely.large,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.padding = padding
        self.action = action
        self.content = content()
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            MovelyCard(variant: variant, padding: padding) {
                content
            }
        }
        .buttonStyle(MovelyCardPressStyle())
    }
}

// MARK: - Card Press Style
private struct MovelyCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Cards - Light") {
    MovelyCardPreview()
        .preferredColorScheme(.light)
}

#Preview("Cards - Dark") {
    MovelyCardPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Preview View
private struct MovelyCardPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: .movely.large) {

                cardSection(title: "Elevated") {
                    MovelyCard {
                        trainerCardContent
                    }
                }

                cardSection(title: "Outlined") {
                    MovelyCard(variant: .outlined) {
                        trainerCardContent
                    }
                }

                cardSection(title: "Filled") {
                    MovelyCard(variant: .filled) {
                        trainerCardContent
                    }
                }

                cardSection(title: "Tappable") {
                    MovelyTappableCard {
                        print("Card tapped")
                    } content: {
                        trainerCardContent
                    }
                }
            }
            .padding(.movely.small)
        }
        .background(.movelyBackground)
    }

    // MARK: - Sample Trainer Card Content
    private var trainerCardContent: some View {
        HStack(spacing: .movely.small) {
            Circle()
                .fill(.movelyPrimary.opacity(0.15))
                .overlay(
                    Circle().strokeBorder(.movelyPrimary, lineWidth: 1.5)
                )
                .frame(
                    width: .movely.avatarMedium,
                    height: .movely.avatarMedium
                )

            VStack(alignment: .leading, spacing: .movely.micro) {
                Text("Carlos Silva")
                    .font(.movely.headline)
                    .foregroundStyle(.movelyTextPrimary)

                Text("Strength & Conditioning")
                    .font(.movely.subheadline)
                    .foregroundStyle(.movelyTextSecondary)

                HStack(spacing: .movely.micro) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.movelyWarning)
                    Text("4.9")
                        .font(.movely.caption1)
                        .foregroundStyle(.movelyTextSecondary)
                    Text("·")
                        .foregroundStyle(.movelyTextDisabled)
                    Text("128 sessions")
                        .font(.movely.caption1)
                        .foregroundStyle(.movelyTextSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: .movely.micro) {
                Text("$45")
                    .font(.movely.price)
                    .foregroundStyle(.movelyPrimary)
                Text("/ hour")
                    .font(.movely.caption1)
                    .foregroundStyle(.movelyTextSecondary)
            }
        }
    }

    // MARK: - Card Section
    private func cardSection(
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
