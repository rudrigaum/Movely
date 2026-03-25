//
//  SearchView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Search View
public struct SearchView: View {

    // MARK: - Dependencies
    @State private var viewModel: SearchViewModel
    @State private var selectedTrainer: Trainer?

    // MARK: - Init
    public init() {
        self._viewModel = State(
            initialValue: SearchViewModel(
                searchUseCase: SearchTrainersUseCaseMock()
            )
        )
    }

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBarSection
                categoriesSection

                Divider()

                contentSection
            }
            .movelyScreen()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedTrainer) { trainer in
                TrainerProfileView(trainerId: trainer.id)
            }
            .task { await viewModel.onAppear() }
        }
    }

    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        HStack(spacing: .movely.small) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.movelyTextSecondary)

            TextField("Search trainers, specialties...", text: Binding(
                get: { viewModel.searchQuery },
                set: { viewModel.searchQuery = $0 }
            ))
            .font(.movely.body)
            .foregroundStyle(.movelyTextPrimary)
            .autocorrectionDisabled()
            .onChange(of: viewModel.searchQuery) { _, _ in
                viewModel.onQueryChanged()
            }

            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                    viewModel.onQueryChanged()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.movelyTextSecondary)
                }
            }
        }
        .padding(.movely.small)
        .background(.movelyBackgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: .movely.radiusMedium))
        .padding(.horizontal, .movely.screenPaddingHorizontal)
        .padding(.vertical, .movely.small)
    }

    // MARK: - Categories Section
    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .movely.tiny) {
                ForEach(TrainingCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.onCategorySelected(category)
                    }
                }
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
        }
        .padding(.bottom, .movely.small)
    }

    // MARK: - Content Section
    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.viewState {
        case .idle:
            idleSection
        case .loading:
            loadingSection
        case .loaded(let trainers):
            loadedSection(trainers: trainers)
        case .empty:
            emptySection
        case .failure(let message):
            errorSection(message: message)
        }
    }

    // MARK: - Idle Section
    private var idleSection: some View {
        VStack(spacing: .movely.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.movelyTextSecondary.opacity(0.5))

            Text("Search for trainers")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loading Section
    private var loadingSection: some View {
        let columns = [
            GridItem(.flexible(), spacing: .movely.small),
            GridItem(.flexible(), spacing: .movely.small)
        ]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: .movely.small) {
                ForEach(0..<6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: .movely.radiusLarge)
                        .fill(.movelyBackgroundElevated)
                        .frame(height: 200)
                        .movelyShimmer(isLoading: true)
                }
            }
            .padding(.movely.screenPaddingHorizontal)
            .padding(.top, .movely.small)
        }
    }

    // MARK: - Loaded Section
    private func loadedSection(trainers: [Trainer]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .movely.small) {
                Text("\(trainers.count) trainer\(trainers.count == 1 ? "" : "s") found")
                    .font(.movely.caption1)
                    .foregroundStyle(.movelyTextSecondary)
                    .padding(.horizontal, .movely.screenPaddingHorizontal)

                let columns = [
                    GridItem(.flexible(), spacing: .movely.small),
                    GridItem(.flexible(), spacing: .movely.small)
                ]

                LazyVGrid(columns: columns, spacing: .movely.small) {
                    ForEach(trainers) { trainer in
                        TrainerCard(trainer: trainer) {
                            selectedTrainer = trainer
                        }
                    }
                }
                .padding(.horizontal, .movely.screenPaddingHorizontal)
            }
            .padding(.top, .movely.small)
            .padding(.bottom, .movely.large)
        }
    }

    // MARK: - Empty Section
    private var emptySection: some View {
        VStack(spacing: .movely.medium) {
            Image(systemName: "person.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(.movelyTextSecondary.opacity(0.5))

            Text("No trainers found")
                .font(.movely.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextPrimary)

            Text("Try adjusting your search or removing filters")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)

            if viewModel.selectedCategory != nil || !viewModel.searchQuery.isEmpty {
                MovelyButton("Clear Filters", variant: .secondary) {
                    viewModel.searchQuery = ""
                    viewModel.selectedCategory = nil
                    viewModel.onQueryChanged()
                }
            }
        }
        .padding(.movely.screenPaddingHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// MARK: - Press Style
private struct MovelyPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Search - Loaded") {
    SearchView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}

#Preview("Search - Dark") {
    SearchView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
        .preferredColorScheme(.dark)
}

#Preview("Search - Empty") {
    let view = SearchView()
    return view
        .environment(AppEnvironment.mock(isAuthenticated: true))
}
