//
//  MovelyViewModifiers.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/03/26.
//

import SwiftUI

// MARK: - Screen Modifier
/// Applies standard screen background and safe area padding.
/// Usage: .movelyScreen()
struct MovelyScreenModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.movelyBackground)
            .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Section Header Modifier
/// Applies standard section header style.
/// Usage: Text("Section").movleySectionHeader()
struct MovelySectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.movely.title3)
            .foregroundStyle(.movelyTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .movely.screenPaddingHorizontal)
    }
}

// MARK: - Badge Modifier
/// Applies badge style for tags and labels.
/// Usage: Text("Pro").movelyBadge(color: .movelyPrimary)
struct MovelyBadgeModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(.movely.badge)
            .foregroundStyle(color)
            .padding(.horizontal, .movely.tiny)
            .padding(.vertical, .movely.micro)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: .movely.radiusFull))
    }
}

// MARK: - Shimmer Modifier
/// Applies a shimmer loading effect.
/// Usage: Rectangle().movelyShimmer(isLoading: true)
struct MovelyShimmerModifier: ViewModifier {
    let isLoading: Bool

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isLoading {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white.opacity(0.4), location: 0.4),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .init(x: phase - 0.5, y: 0.5),
                            endPoint: .init(x: phase + 0.5, y: 0.5)
                        )
                        .frame(width: geometry.size.width)
                    }
                )
                .clipped()
                .onAppear {
                    withAnimation(
                        .linear(duration: 1.4)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1.5
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Divider Modifier
/// Applies a standard Movely divider below the content.
/// Usage: Text("Section").movelyDivider()
struct MovelyDividerModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            Rectangle()
                .fill(.movelyDivider)
                .frame(height: 1)
                .padding(.horizontal, .movely.screenPaddingHorizontal)
        }
    }
}

// MARK: - View Extensions
public extension View {

    /// Applies standard screen background and padding.
    func movelyScreen() -> some View {
        modifier(MovelyScreenModifier())
    }

    /// Applies standard section header style.
    func movleySectionHeader() -> some View {
        modifier(MovelySectionHeaderModifier())
    }

    /// Applies badge style with a given color.
    func movelyBadge(color: Color = .movelyPrimary) -> some View {
        modifier(MovelyBadgeModifier(color: color))
    }

    /// Applies shimmer loading effect.
    func movelyShimmer(isLoading: Bool) -> some View {
        modifier(MovelyShimmerModifier(isLoading: isLoading))
    }

    /// Applies a standard divider below the content.
    func movelyDivider() -> some View {
        modifier(MovelyDividerModifier())
    }
}

// MARK: - Preview
#Preview("ViewModifiers - Light") {
    MovelyViewModifiersPreview()
        .preferredColorScheme(.light)
}

#Preview("ViewModifiers - Dark") {
    MovelyViewModifiersPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Preview View
private struct MovelyViewModifiersPreview: View {
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .movely.large) {

                // MARK: Section Header
                previewSection(title: "Section Header") {
                    Text("Nearby Trainers")
                        .movleySectionHeader()
                }

                // MARK: Badges
                previewSection(title: "Badges") {
                    HStack(spacing: .movely.tiny) {
                        Text("Pro").movelyBadge(color: .movelyPrimary)
                        Text("Online").movelyBadge(color: .movelySuccess)
                        Text("New").movelyBadge(color: .movelyAccent)
                        Text("Busy").movelyBadge(color: .movelyError)
                    }
                    .padding(.horizontal, .movely.screenPaddingHorizontal)
                }

                // MARK: Shimmer
                previewSection(title: "Shimmer Loading") {
                    VStack(spacing: .movely.tiny) {
                        RoundedRectangle(cornerRadius: .movely.radiusMedium)
                            .fill(.movelyBackgroundGrouped)
                            .frame(height: 80)
                            .movelyShimmer(isLoading: isLoading)

                        RoundedRectangle(cornerRadius: .movely.radiusMedium)
                            .fill(.movelyBackgroundGrouped)
                            .frame(height: 80)
                            .movelyShimmer(isLoading: isLoading)
                    }
                    .padding(.horizontal, .movely.screenPaddingHorizontal)

                    Button(isLoading ? "Stop Shimmer" : "Start Shimmer") {
                        isLoading.toggle()
                    }
                    .padding(.horizontal, .movely.screenPaddingHorizontal)
                }

                // MARK: Divider
                previewSection(title: "Divider") {
                    Text("Item 1")
                        .padding(.movely.small)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .movelyDivider()

                    Text("Item 2")
                        .padding(.movely.small)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .movelyDivider()

                    Text("Item 3")
                        .padding(.movely.small)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, .movely.small)
        }
        .movelyScreen()
    }

    private func previewSection(
        title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: .movely.tiny) {
            Text(title.uppercased())
                .font(.movely.caption1)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextSecondary)
                .padding(.horizontal, .movely.screenPaddingHorizontal)
            Divider()
            content()
        }
    }
}
