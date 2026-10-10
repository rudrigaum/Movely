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

    @Environment(\.dismiss) private var dismiss
    @Environment(AppEnvironment.self) private var env

    // MARK: - Properties

    private let trainerId: String

    // MARK: - State

    @State private var viewModel: TrainerProfileViewModel?
    @State private var isShowingBookingSheet = false

    // MARK: - Initialization

    public init(trainerId: String) {
        self.trainerId = trainerId
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let viewModel {
                    switch viewModel.viewState {
                    case .idle, .loading:
                        loadingSection

                    case .loaded(let trainer):
                        loadedContent(trainer: trainer)

                    case .failure(let message):
                        errorSection(
                            message: message,
                            viewModel: viewModel
                        )
                    }
                } else {
                    loadingSection
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .contentMargins(.bottom, 120, for: .scrollContent)
        .movelyScreen()
        .navigationBarBackButtonHidden()
        .toolbar {
            backButton
        }
        .task {
            await setupViewModelIfNeeded()
        }
        .safeAreaInset(edge: .bottom) {
            if let viewModel, viewModel.trainer != nil {
                bookingBar(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $isShowingBookingSheet) {
            bookingSheet
        }
    }

    // MARK: - Loaded Content

    private func loadedContent(
        trainer: Trainer
    ) -> some View {
        VStack(spacing: .movely.xLarge) {
            TrainerProfileHeaderView(
                trainer: trainer
            )

            VStack(spacing: .movely.xLarge) {
                specialtiesSection(trainer: trainer)
                bioSection(trainer: trainer)

                TrainerProfileDetailsView(
                    trainer: trainer
                )
            }
            .padding(
                .horizontal,
                .movely.screenPaddingHorizontal
            )
            .padding(.bottom, 120)
        }
    }

    // MARK: - Specialties Section

    private func specialtiesSection(
        trainer: Trainer
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: .movely.small
        ) {
            SectionTitle(text: "Specialties")

            FlowLayout(spacing: .movely.tiny) {
                ForEach(trainer.specialties) { specialty in
                    SpecialtyChip(category: specialty)
                }
            }
        }
    }

    // MARK: - Bio Section

    private func bioSection(
        trainer: Trainer
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: .movely.small
        ) {
            SectionTitle(text: "About")

            Text(trainer.bio)
                .font(.movely.body)
                .foregroundStyle(.movelyTextSecondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Booking Bar

    private func bookingBar(
        viewModel: TrainerProfileViewModel
    ) -> some View {
        HStack(spacing: .movely.small) {
            VStack(
                alignment: .leading,
                spacing: 2
            ) {
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

            if let trainer = viewModel.trainer {
                MovelyButton(
                    trainer.isAvailable
                        ? "Book Session"
                        : "Unavailable",
                    isFullWidth: true
                ) {
                    isShowingBookingSheet = true
                }
                .disabled(!trainer.isAvailable)
                .opacity(trainer.isAvailable ? 1 : 0.5)
            }
        }
        .padding(
            .horizontal,
            .movely.screenPaddingHorizontal
        )
        .padding(
            .vertical,
            .movely.medium
        )
        .background(.movelyBackground)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    // MARK: - Booking Sheet

    @ViewBuilder
    private var bookingSheet: some View {
        if let studentId = env.currentUser?.id,
           let viewModel,
           let trainer = viewModel.trainer,
           trainer.isAvailable {
            NavigationStack {
                CreateBookingView(
                    viewModel: CreateBookingViewModel(
                        trainerId: trainer.id,
                        studentId: studentId,
                        createBookingUseCase: env.createBookingUseCase
                    )
                )
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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
                    RoundedRectangle(
                        cornerRadius: .movely.radiusMedium
                    )
                    .fill(.movelyBackgroundElevated)
                    .frame(height: 20)
                    .movelyShimmer(isLoading: true)
                }
            }
            .padding(
                .horizontal,
                .movely.screenPaddingHorizontal
            )
        }
    }

    // MARK: - Error Section

    private func errorSection(
        message: String,
        viewModel: TrainerProfileViewModel
    ) -> some View {
        VStack(spacing: .movely.large) {
            Image(
                systemName: "exclamationmark.triangle.fill"
            )
            .font(.system(size: 48))
            .foregroundStyle(.movelyError)

            Text(message)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)

            MovelyButton("Try Again") {
                Task {
                    await viewModel.onRetry()
                }
            }
        }
        .padding(.movely.screenPaddingHorizontal)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding(.top, .movely.xxxLarge)
    }

    // MARK: - Setup

    private func setupViewModelIfNeeded() async {
        if viewModel == nil {
            viewModel = TrainerProfileViewModel(
                trainerId: trainerId,
                repository: env.trainerRepository
            )
        }

        await viewModel?.onAppear()
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

    // MARK: - Properties

    let text: String

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(.movely.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.movelyTextPrimary)
    }

}

// MARK: - Specialty Chip

private struct SpecialtyChip: View {

    // MARK: - Properties

    let category: TrainingCategory

    // MARK: - Body

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
        .overlay {
            Capsule()
                .strokeBorder(
                    .movelyPrimary.opacity(0.3),
                    lineWidth: 1
                )
        }
    }

}

// MARK: - Preview

#if DEBUG

#Preview("Trainer Profile - Loaded") {
    NavigationStack {
        TrainerProfileView(trainerId: "1")
            .environment(
                AppEnvironment.mock(isAuthenticated: true)
            )
    }
}

#Preview("Trainer Profile - Dark") {
    NavigationStack {
        TrainerProfileView(trainerId: "1")
            .environment(
                AppEnvironment.mock(isAuthenticated: true)
            )
    }
    .preferredColorScheme(.dark)
}

#Preview("Trainer Profile - Unavailable") {
    NavigationStack {
        TrainerProfileView(trainerId: "3")
            .environment(
                AppEnvironment.mock(isAuthenticated: true)
            )
    }
}

#endif
