//
//  HomeViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 16/03/26.
//

import Foundation
import SwiftUI

// MARK: - Home View State
public enum HomeViewState: Equatable {
    case idle
    case loading
    case loaded
    case failure(String)
}

// MARK: - HomeViewModel
@Observable
@MainActor
public final class HomeViewModel {

    // MARK: - State
    public var viewState: HomeViewState = .idle
    public var featuredTrainers: [Trainer] = []
    public var nearbyTrainers: [Trainer] = []
    public var selectedCategory: TrainingCategory?

    // MARK: - Computed
    public var isLoading: Bool { viewState == .loading }

    public var errorMessage: String? {
        if case .failure(let message) = viewState { return message }
        return nil
    }

    // MARK: - Dependencies
    private let fetchFeaturedUseCase: FetchFeaturedTrainersUseCaseProtocol
    private let fetchNearbyUseCase: FetchNearbyTrainersUseCaseProtocol

    // MARK: - Init
    public init(
        fetchFeaturedUseCase: FetchFeaturedTrainersUseCaseProtocol,
        fetchNearbyUseCase: FetchNearbyTrainersUseCaseProtocol
    ) {
        self.fetchFeaturedUseCase = fetchFeaturedUseCase
        self.fetchNearbyUseCase = fetchNearbyUseCase
    }

    // MARK: - Actions
    public func onAppear() async {
        guard viewState == .idle else { return }
        await fetchAll()
    }

    public func onRefresh() async {
        await fetchAll()
    }

    public func selectCategory(_ category: TrainingCategory) {
        selectedCategory = selectedCategory == category ? nil : category
    }

    // MARK: - Private
    private func fetchAll() async {
        viewState = .loading

        do {
            async let featured = fetchFeaturedUseCase.execute()
            async let nearby = fetchNearbyUseCase.execute(limit: 4)

            let (fetchedFeatured, fetchedNearby) = try await (featured, nearby)

            featuredTrainers = fetchedFeatured
            nearbyTrainers = fetchedNearby
            viewState = .loaded
        } catch {
            viewState = .failure(error.localizedDescription)
        }
    }
}
