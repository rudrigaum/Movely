//
//  HomeView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import SwiftUI

// MARK: - Home View
public struct HomeView: View {

    // MARK: - Dependencies
    @State private var viewModel: HomeViewModel?
    @State private var selectedTrainer: Trainer?
    @Environment(AppEnvironment.self) private var env

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    homeContent(viewModel: viewModel)
                }
            }
            .navigationDestination(item: $selectedTrainer) { trainer in
                TrainerProfileView(trainerId: trainer.id)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(
                    fetchFeaturedUseCase: env.fetchFeaturedUseCase,
                    fetchNearbyUseCase: env.fetchNearbyUseCase
                )
                await viewModel?.onAppear()
            }
        }
    }

    // MARK: - Home Content
    @ViewBuilder
    private func homeContent(viewModel: HomeViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .movely.xLarge) {
                welcomeSection
                categoriesSection(viewModel: viewModel)
                featuredSection(viewModel: viewModel)
                nearbySection(viewModel: viewModel)
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.vertical, .movely.large)
        }
        .movelyScreen()
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await viewModel.onRefresh() }
    }

    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: .movely.micro) {
            Text("Good \(timeOfDayGreeting) 👋")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)

            Text(env.currentUser?.name.components(separatedBy: " ").first ?? "Athlete")
                .font(.movely.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.movelyTextPrimary)

            Text("Find your perfect trainer today")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
        }
    }

    // MARK: - Categories Section
    private func categoriesSection(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            SectionHeader(title: "Categories")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .movely.tiny) {
                    ForEach(TrainingCategory.allCases) { category in
                        CategoryChip(
                            category: category,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectCategory(category)
                        }
                    }
                }
                .padding(.horizontal, .movely.screenPaddingHorizontal)
            }
            .padding(.horizontal, -.movely.screenPaddingHorizontal)
        }
    }

    // MARK: - Featured Section
    private func featuredSection(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            SectionHeader(title: "Featured Trainers")

            if viewModel.isLoading {
                TrainerGridSkeleton()
            } else {
                TrainerGrid(
                    trainers: viewModel.featuredTrainers,
                    onTap: { trainer in
                        selectedTrainer = trainer
                    }
                )
            }
        }
    }

    // MARK: - Nearby Section
    private func nearbySection(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            SectionHeader(title: "Nearby Trainers")

            if viewModel.isLoading {
                TrainerGridSkeleton()
            } else {
                TrainerGrid(
                    trainers: viewModel.nearbyTrainers,
                    onTap: { trainer in
                        selectedTrainer = trainer
                    }
                )
            }
        }
    }

    // MARK: - Time Greeting
    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<18: return "afternoon"
        default: return "evening"
        }
    }
}

    // MARK: - Section Header
    private struct SectionHeader: View {
        let title: String

        var body: some View {
            Text(title)
                .font(.movely.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextPrimary)
        }
    }

    // MARK: - Category Chip
    private struct CategoryChip: View {
        let category: TrainingCategory
        let isSelected: Bool
        let onTap: () -> Void

        var body: some View {
            Button(action: onTap) {
                HStack(spacing: .movely.micro) {
                    Image(systemName: category.icon)
                        .font(.system(size: 12))
                    Text(category.rawValue)
                        .font(.movely.caption1)
                        .fontWeight(.medium)
                }
                .foregroundStyle(isSelected ? .white : .movelyTextPrimary)
                .padding(.horizontal, .movely.small)
                .padding(.vertical, .movely.tiny)
                .background(isSelected ? .movelyPrimary : .movelyBackgroundElevated)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? .clear : .movelyBorder, lineWidth: 1)
                )
            }
            .buttonStyle(MovelyPressButtonStyle())
        }
    }

    // MARK: - Trainer Grid
    private struct TrainerGrid: View {
        let trainers: [Trainer]
        let onTap: (Trainer) -> Void

        private let columns = [
            GridItem(.flexible(), spacing: .movely.small),
            GridItem(.flexible(), spacing: .movely.small)
        ]

        var body: some View {
            LazyVGrid(columns: columns, spacing: .movely.small) {
                ForEach(trainers) { trainer in
                    TrainerCard(trainer: trainer) {
                        onTap(trainer)
                    }
                }
            }
        }
    }

    // MARK: - Trainer Grid Skeleton
    private struct TrainerGridSkeleton: View {
        private let columns = [
            GridItem(.flexible(), spacing: .movely.small),
            GridItem(.flexible(), spacing: .movely.small)
        ]

        var body: some View {
            LazyVGrid(columns: columns, spacing: .movely.small) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: .movely.radiusLarge)
                        .fill(.movelyBackgroundElevated)
                        .frame(height: 200)
                        .movelyShimmer(isLoading: true)
                }
            }
        }
    }

    // MARK: - Press Style
    private struct MovelyPressButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    // MARK: - Preview
    #Preview("Home - Loaded") {
        HomeView()
            .environment(AppEnvironment.mock(isAuthenticated: true))
    }

    #Preview("Home - Dark") {
        HomeView()
            .environment(AppEnvironment.mock(isAuthenticated: true))
            .preferredColorScheme(.dark)
    }
