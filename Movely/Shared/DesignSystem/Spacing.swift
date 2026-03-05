//
//  Spacing.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/03/26.
//

import SwiftUI

// MARK: - Spacing
public extension CGFloat {
    static let movely = MovelySpacing()
}

// MARK: - MovelySpacing
public struct MovelySpacing {

    // MARK: - Base Grid (4pt)
    /// 4pt — micro spacing, icon padding, tight gaps
    public var micro: CGFloat { 4 }

    /// 8pt — tiny spacing, inner element gaps
    public var tiny: CGFloat { 8 }

    /// 12pt — compact spacing
    public var compact: CGFloat { 12 }

    /// 16pt — small spacing, standard padding
    public var small: CGFloat { 16 }

    /// 20pt — medium spacing
    public var medium: CGFloat { 20 }

    /// 24pt — large spacing, card padding
    public var large: CGFloat { 24 }

    /// 32pt — xLarge spacing, section gaps
    public var xLarge: CGFloat { 32 }

    /// 40pt — xxLarge spacing
    public var xxLarge: CGFloat { 40 }

    /// 48pt — xxxLarge spacing, section header spacing
    public var xxxLarge: CGFloat { 48 }

    /// 64pt — huge spacing, screen-level spacing
    public var huge: CGFloat { 64 }

    // MARK: - Corner Radius
    /// 4pt — subtle rounding, tags
    public var radiusTiny: CGFloat { 4 }

    /// 8pt — small cards and inputs
    public var radiusSmall: CGFloat { 8 }

    /// 12pt — standard cards
    public var radiusMedium: CGFloat { 12 }

    /// 16pt — large cards and modals
    public var radiusLarge: CGFloat { 16 }

    /// 24pt — bottom sheets
    public var radiusXLarge: CGFloat { 24 }

    /// 999pt — fully rounded, pills and buttons
    public var radiusFull: CGFloat { 999 }

    // MARK: - Icon Sizes
    /// 16pt — inline icons
    public var iconSmall: CGFloat { 16 }

    /// 24pt — standard icons
    public var iconMedium: CGFloat { 24 }

    /// 32pt — large icons
    public var iconLarge: CGFloat { 32 }

    /// 48pt — feature icons
    public var iconXLarge: CGFloat { 48 }

    // MARK: - Avatar Sizes
    /// 32pt — small avatar, comments and lists
    public var avatarSmall: CGFloat { 32 }

    /// 48pt — standard avatar, cards
    public var avatarMedium: CGFloat { 48 }

    /// 64pt — large avatar, profile header
    public var avatarLarge: CGFloat { 64 }

    /// 96pt — extra large avatar, profile screen
    public var avatarXLarge: CGFloat { 96 }

    // MARK: - Button
    /// Standard button height
    public var buttonHeight: CGFloat { 56 }

    /// Small button height
    public var buttonHeightSmall: CGFloat { 44 }

    /// Standard button horizontal padding
    public var buttonPaddingHorizontal: CGFloat { 24 }

    // MARK: - Input
    /// Standard input field height
    public var inputHeight: CGFloat { 56 }

    // MARK: - Screen
    /// Standard horizontal screen padding
    public var screenPaddingHorizontal: CGFloat { 16 }

    /// Standard vertical screen padding
    public var screenPaddingVertical: CGFloat { 24 }

    // MARK: - Tab Bar
    /// Tab bar height
    public var tabBarHeight: CGFloat { 83 }
}

// MARK: - Preview
#Preview("Spacing - Light") {
    SpacingPreview()
        .preferredColorScheme(.light)
}

#Preview("Spacing - Dark") {
    SpacingPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Preview View
private struct SpacingPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .movely.large) {

                spacingSection(title: "Base Grid (4pt)") {
                    spacingRow("micro", value: .movely.micro)
                    spacingRow("tiny", value: .movely.tiny)
                    spacingRow("compact", value: .movely.compact)
                    spacingRow("small", value: .movely.small)
                    spacingRow("medium", value: .movely.medium)
                    spacingRow("large", value: .movely.large)
                    spacingRow("xLarge", value: .movely.xLarge)
                    spacingRow("xxLarge", value: .movely.xxLarge)
                    spacingRow("huge", value: .movely.huge)
                }

                spacingSection(title: "Corner Radius") {
                    radiusRow("radiusTiny", value: .movely.radiusTiny)
                    radiusRow("radiusSmall", value: .movely.radiusSmall)
                    radiusRow("radiusMedium", value: .movely.radiusMedium)
                    radiusRow("radiusLarge", value: .movely.radiusLarge)
                    radiusRow("radiusXLarge", value: .movely.radiusXLarge)
                }

                spacingSection(title: "Avatars") {
                    avatarRow("avatarSmall", size: .movely.avatarSmall)
                    avatarRow("avatarMedium", size: .movely.avatarMedium)
                    avatarRow("avatarLarge", size: .movely.avatarLarge)
                    avatarRow("avatarXLarge", size: .movely.avatarXLarge)
                }
            }
            .padding(.movely.small)
        }
        .background(.movelyBackground)
    }

    private func spacingSection(
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

    private func spacingRow(_ name: String, value: CGFloat) -> some View {
        HStack(spacing: .movely.small) {
            Rectangle()
                .fill(.movelyPrimary)
                .frame(width: value, height: .movely.iconSmall)
                .clipShape(RoundedRectangle(cornerRadius: .movely.radiusTiny))
            Text(name)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextPrimary)
            Spacer()
            Text("\(Int(value))pt")
                .font(.movely.caption1)
                .foregroundStyle(.movelyTextSecondary)
        }
    }

    private func radiusRow(_ name: String, value: CGFloat) -> some View {
        HStack(spacing: .movely.small) {
            RoundedRectangle(cornerRadius: value)
                .fill(.movelyPrimary.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: value)
                        .strokeBorder(.movelyPrimary, lineWidth: 1.5)
                )
                .frame(width: 44, height: 44)
            Text(name)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextPrimary)
            Spacer()
            Text("\(Int(value))pt")
                .font(.movely.caption1)
                .foregroundStyle(.movelyTextSecondary)
        }
    }

    private func avatarRow(_ name: String, size: CGFloat) -> some View {
        HStack(spacing: .movely.small) {
            Circle()
                .fill(.movelyPrimary.opacity(0.15))
                .overlay(
                    Circle().strokeBorder(.movelyPrimary, lineWidth: 1.5)
                )
                .frame(width: size, height: size)
            Text(name)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextPrimary)
            Spacer()
            Text("\(Int(size))pt")
                .font(.movely.caption1)
                .foregroundStyle(.movelyTextSecondary)
        }
    }
}
