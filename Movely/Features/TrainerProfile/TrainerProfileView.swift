//
//  TrainerProfileView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 17/03/26.
//

import Foundation
import SwiftUI

// MARK: - Trainer Profile View
public struct TrainerProfileView: View {
    // MARK: - Dependencies
    @State private var viewModel: TrainerProfileViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init
    public init(trainerId: String) {
        self._viewModel = State(
            initialValue: TrainerProfileViewModel(
                trainerId: trainerId,
                repository: TrainerRepositoryMock()
            )
        )
    }

    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    switch viewModel.viewState {
                    case .idle, .loading:
                        loadingSection
                    case .loaded(let trainer):
                        loadedContent(trainer: trainer)
                    case .failure(let message):
                        errorSection(message: message)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            if viewModel.trainer != nil {
                bookingBar
            }
        }
        .movelyScreen()
        .navigationBarBackButtonHidden()
        .toolbar { backButton }
        .task { await viewModel.onAppear() }
    }

    // MARK: - Loaded Content
    @ViewBuilder
    private func loadedContent(trainer: Trainer) -> some View {
        VStack(spacing: .movely.xLarge) {
            headerSection(trainer: trainer)

            VStack(spacing: .movely.xLarge) {
                specialtiesSection(trainer: trainer)
                bioSection(trainer: trainer)
                detailsSection(trainer: trainer)
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Header Section
    private func headerSection(trainer: Trainer) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.movelyPrimary.opacity(0.8), .movelyPrimary.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)

            VStack(alignment: .leading, spacing: .movely.small) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: .movely.avatarXLarge, height: .movely.avatarXLarge)

                        Text(trainer.name.prefix(1))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(.top, 60)

                VStack(alignment: .leading, spacing: .movely.micro) {
                    Text(trainer.name)
                        .font(.movely.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Label(trainer.location.displayName, systemImage: "location.fill")
                        .font(.movely.subheadline)
                        .foregroundStyle(.white.opacity(0.85))

                    HStack(spacing: .movely.tiny) {
                        ratingStars(rating: trainer.rating)

                        Text(String(format: "%.1f", trainer.rating))
                            .font(.movely.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text("(\(trainer.reviewCount) reviews)")
                            .font(.movely.caption1)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.bottom, .movely.large)
        }
    }
    // MARK: - Specialties Section
    private func specialtiesSection(trainer: Trainer) -> some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            SectionTitle(text: "Specialties")

            FlowLayout(spacing: .movely.tiny) {
                ForEach(trainer.specialties) { specialty in
                    SpecialtyChip(category: specialty)
                }
            }
        }
    }

    // MARK: - Bio Section
    private func bioSection(trainer: Trainer) -> some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            SectionTitle(text: "About")

            Text(trainer.bio)
                .font(.movely.body)
                .foregroundStyle(.movelyTextSecondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Details Section
    private func detailsSection(trainer: Trainer) -> some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            SectionTitle(text: "Details")

            MovelyCard {
                VStack(spacing: 0) {
                    DetailRow(
                        icon: "clock.fill",
                        title: "Hourly Rate",
                        value: "R$ \(Int(trainer.hourlyRate))/hr"
                    )
                    Divider().padding(.leading, 44)
                    DetailRow(
                        icon: "location.fill",
                        title: "Distance",
                        value: trainer.location.distanceText ?? "N/A"
                    )
                    Divider().padding(.leading, 44)
                    DetailRow(
                        icon: "checkmark.seal.fill",
                        title: "Availability",
                        value: trainer.isAvailable ? "Available now" : "Unavailable"
                    )
                }
            }
        }
    }

    // MARK: - Booking Bar
    private var bookingBar: some View {
        HStack(spacing: .movely.small) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Starting at")
                    .font(.movely.caption1)
                    .foregroundStyle(.movelyTextSecondary)
                if let trainer = viewModel.trainer {
                    Text("R$ \(Int(trainer.hourlyRate))/hr")
                        .font(.movely.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.movelyPrimary)
                }
            }

            MovelyButton("Book Session", isFullWidth: true) {
                // Navigation to Booking — coming soon
            }
        }
        .padding(.horizontal, .movely.screenPaddingHorizontal)
        .padding(.vertical, .movely.medium)
        .background(.movelyBackground)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    // MARK: - Loading Section
    private var loadingSection: some View {
        VStack(spacing: .movely.large) {
            RoundedRectangle(cornerRadius: 0)
                .fill(.movelyBackgroundElevated)
                .frame(height: 280)
                .movelyShimmer(isLoading: true)

            VStack(spacing: .movely.small) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: .movely.radiusMedium)
                        .fill(.movelyBackgroundElevated)
                        .frame(height: 20)
                        .movelyShimmer(isLoading: true)
                }
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
        }
    }

    // MARK: - Error Section
    private func errorSection(message: String) -> some View {
        VStack(spacing: .movely.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.movelyError)

            Text(message)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)

            MovelyButton("Try Again") {
                Task { await viewModel.onRetry() }
            }
        }
        .padding(.movely.screenPaddingHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, .movely.xxxLarge)
    }

    // MARK: - Rating Stars
    private func ratingStars(rating: Double) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= Int(rating.rounded()) ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(.movelyWarning)
            }
        }
    }

    // MARK: - Back Button
    private var backButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.3))
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Section Title
private struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.movely.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.movelyTextPrimary)
    }
}

// MARK: - Specialty Chip
private struct SpecialtyChip: View {
    let category: TrainingCategory
    var body: some View {
        HStack(spacing: .movely.micro) {
            Image(systemName: category.icon)
                .font(.system(size: 11))
            Text(category.rawValue)
                .font(.movely.caption1)
                .fontWeight(.medium)
        }
        .foregroundStyle(.movelyPrimary)
        .padding(.horizontal, .movely.small)
        .padding(.vertical, .movely.tiny)
        .background(.movelyPrimary.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(.movelyPrimary.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Detail Row
private struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: .movely.small) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.movelyPrimary)
                .frame(width: 28)

            Text(title)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)

            Spacer()

            Text(value)
                .font(.movely.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.movelyTextPrimary)
        }
        .padding(.movely.medium)
    }
}

// MARK: - Flow Layout
private struct FlowLayout: Layout {
    let spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
            .reduce(0) { $0 + $1 + spacing }
        return CGSize(width: proposal.width ?? 0, height: max(0, height - spacing))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var offsetY = bounds.minY
        for row in rows {
            var offsetX = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: offsetX, y: offsetY), proposal: .unspecified)
                offsetX += size.width + spacing
            }
            offsetY += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var offsetX: CGFloat = 0
        let maxWidth = proposal.width ?? 0

        for subview in subviews {
            let width = subview.sizeThatFits(.unspecified).width
            if offsetX + width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                offsetX = 0
            }
            rows[rows.count - 1].append(subview)
            offsetX += width + spacing
        }
        return rows
    }
}

// MARK: - Preview
#Preview("Trainer Profile - Loaded") {
    NavigationStack {
        TrainerProfileView(trainerId: "1")
            .environment(AppEnvironment.mock(isAuthenticated: true))
    }
}

#Preview("Trainer Profile - Dark") {
    NavigationStack {
        TrainerProfileView(trainerId: "2")
            .environment(AppEnvironment.mock(isAuthenticated: true))
            .preferredColorScheme(.dark)
    }
}
