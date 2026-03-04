//
//  Typography.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 04/03/26.
//

import Foundation
import SwiftUI

// MARK: - Typography
public extension Font {
    static let movely = MovelyFonts()
}

// MARK: - MovelyFonts
public struct MovelyFonts {

    // MARK: - Display
    public var display: Font { .system(size: 40, weight: .bold, design: .rounded) }

    // MARK: - Headings
    public var largeTitle: Font { .system(size: 34, weight: .bold, design: .rounded) }

    public var title1: Font { .system(size: 28, weight: .bold, design: .rounded) }

    public var title2: Font { .system(size: 22, weight: .semibold, design: .rounded) }

    public var title3: Font { .system(size: 20, weight: .semibold, design: .rounded) }

    // MARK: - Body
    public var headline: Font { .system(size: 17, weight: .semibold, design: .default) }

    public var body: Font { .system(size: 17, weight: .regular, design: .default) }

    public var callout: Font { .system(size: 16, weight: .regular, design: .default) }

    public var subheadline: Font { .system(size: 15, weight: .regular, design: .default) }

    // MARK: - Small
    public var footnote: Font { .system(size: 13, weight: .regular, design: .default) }

    public var caption1: Font { .system(size: 12, weight: .regular, design: .default) }

    public var caption2: Font { .system(size: 11, weight: .regular, design: .default) }

    // MARK: - Special
    public var button: Font { .system(size: 17, weight: .semibold, design: .rounded) }

    public var tabBar: Font { .system(size: 10, weight: .medium, design: .default) }

    public var badge: Font { .system(size: 12, weight: .semibold, design: .rounded) }

    public var price: Font { .system(size: 24, weight: .bold, design: .rounded) }
}

// MARK: - Preview
#Preview("Typography - Light") {
    TypographyPreview()
        .preferredColorScheme(.light)
}

#Preview("Typography - Dark") {
    TypographyPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Preview View
private struct TypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                typographySection(title: "Display") {
                    fontRow("display", font: .movely.display)
                }
                typographySection(title: "Headings") {
                    fontRow("largeTitle", font: .movely.largeTitle)
                    fontRow("title1", font: .movely.title1)
                    fontRow("title2", font: .movely.title2)
                    fontRow("title3", font: .movely.title3)
                }
                typographySection(title: "Body") {
                    fontRow("headline", font: .movely.headline)
                    fontRow("body", font: .movely.body)
                    fontRow("callout", font: .movely.callout)
                    fontRow("subheadline", font: .movely.subheadline)
                }
                typographySection(title: "Small") {
                    fontRow("footnote", font: .movely.footnote)
                    fontRow("caption1", font: .movely.caption1)
                    fontRow("caption2", font: .movely.caption2)
                }
                typographySection(title: "Special") {
                    fontRow("button", font: .movely.button)
                    fontRow("tabBar", font: .movely.tabBar)
                    fontRow("badge", font: .movely.badge)
                    fontRow("price", font: .movely.price)
                }
            }
            .padding()
        }
        .background(.movelyBackground)
    }

    private func typographySection(
        title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.movely.caption1)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextSecondary)
            Divider()
            content()
        }
    }

    private func fontRow(_ name: String, font: Font) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Movely")
                .font(font)
                .foregroundStyle(.movelyTextPrimary)
            Spacer()
            Text(name)
                .font(.movely.caption2)
                .foregroundStyle(.movelyTextSecondary)
        }
    }
}
