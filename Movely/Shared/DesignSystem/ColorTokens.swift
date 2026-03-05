//
//  ColorTokens.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 04/03/26.
//

import Foundation
import SwiftUI

// MARK: - Hex Color Extension
private extension Color {
    init(light: String, dark: String) {
        self.init(uiColor: UIColor(
            light: UIColor(hex: light),
            dark: UIColor(hex: dark)
        ))
    }
}

private extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { $0.userInterfaceStyle == .dark ? dark : light }
    }

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue, alpha: UInt64
        switch hex.count {
        case 6: (red, green, blue, alpha) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: (red, green, blue, alpha) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (red, green, blue, alpha) = (0, 0, 0, 255)
        }
        self.init(
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            alpha: Double(alpha) / 255
        )
    }
}

// MARK: - Brand Colors
public extension ShapeStyle where Self == Color {

    // MARK: - Brand
    static var movelyPrimary: Color {
        Color(light: "#6C63FF", dark: "#7B74FF")
    }

    static var movelySecondary: Color {
        Color(light: "#FF6584", dark: "#FF7A96")
    }

    static var movelyAccent: Color {
        Color(light: "#43C6AC", dark: "#4DD9BE")
    }

    // MARK: - Background
    static var movelyBackground: Color {
        Color(light: "#F8F9FA", dark: "#0D0D0D")
    }

    static var movelyBackgroundElevated: Color {
        Color(light: "#FFFFFF", dark: "#1C1C1E")
    }

    static var movelyBackgroundGrouped: Color {
        Color(light: "#F2F2F7", dark: "#161618")
    }

    // MARK: - Text
    static var movelyTextPrimary: Color {
        Color(light: "#0D0D0D", dark: "#F5F5F5")
    }

    static var movelyTextSecondary: Color {
        Color(light: "#6B7280", dark: "#9CA3AF")
    }

    static var movelyTextDisabled: Color {
        Color(light: "#C4C4C4", dark: "#3A3A3C")
    }

    // MARK: - Border & Divider
    static var movelyBorder: Color {
        Color(light: "#E5E7EB", dark: "#2C2C2E")
    }

    static var movelyDivider: Color {
        Color(light: "#F3F4F6", dark: "#1C1C1E")
    }

    // MARK: - Feedback
    static var movelySuccess: Color {
        Color(light: "#22C55E", dark: "#34D679")
    }

    static var movelyWarning: Color {
        Color(light: "#F59E0B", dark: "#FBBF24")
    }

    static var movelyError: Color {
        Color(light: "#EF4444", dark: "#F87171")
    }

    static var movelyInfo: Color {
        Color(light: "#3B82F6", dark: "#60A5FA")
    }
}

// MARK: - Preview
#Preview("Color Tokens - Light") {
    ColorTokensPreview()
        .preferredColorScheme(.light)
}

#Preview("Color Tokens - Dark") {
    ColorTokensPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Preview View
private struct ColorTokensPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                colorSection(title: "Brand") {
                    colorRow("movelyPrimary", color: .movelyPrimary)
                    colorRow("movelySecondary", color: .movelySecondary)
                    colorRow("movelyAccent", color: .movelyAccent)
                }
                colorSection(title: "Background") {
                    colorRow("movelyBackground", color: .movelyBackground)
                    colorRow("movelyBackgroundElevated", color: .movelyBackgroundElevated)
                    colorRow("movelyBackgroundGrouped", color: .movelyBackgroundGrouped)
                }
                colorSection(title: "Text") {
                    colorRow("movelyTextPrimary", color: .movelyTextPrimary)
                    colorRow("movelyTextSecondary", color: .movelyTextSecondary)
                    colorRow("movelyTextDisabled", color: .movelyTextDisabled)
                }
                colorSection(title: "Border & Divider") {
                    colorRow("movelyBorder", color: .movelyBorder)
                    colorRow("movelyDivider", color: .movelyDivider)
                }
                colorSection(title: "Feedback") {
                    colorRow("movelySuccess", color: .movelySuccess)
                    colorRow("movelyWarning", color: .movelyWarning)
                    colorRow("movelyError", color: .movelyError)
                    colorRow("movelyInfo", color: .movelyInfo)
                }
            }
            .padding()
        }
        .background(.movelyBackground)
    }

    private func colorSection(
        title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextSecondary)
            content()
        }
    }

    private func colorRow(_ name: String, color: Color) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.movelyBorder, lineWidth: 0.5)
                )
            Text(name)
                .font(.subheadline)
                .foregroundStyle(.movelyTextPrimary)
            Spacer()
        }
    }
}
