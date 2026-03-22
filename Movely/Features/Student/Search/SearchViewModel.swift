//
//  SearchViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 22/03/26.
//

import SwiftUI

// MARK: - Search View State
public enum SearchViewState: Equatable {
    case idle
    case loading
    case loaded([Trainer])
    case empty
    case failure(String)
}

// MARK: - SearchViewModel
@Observable
@MainActor
public final class SearchViewModel {

    // MARK: - Input
    public var searchQuery: String = ""
    public var selectedCategory: TrainingCategory?

    // MARK: - State
    public var viewState: SearchViewState = .idle

    // MARK: - Computed
    public var isLoading: Bool { viewState == .loading }

    public var trainers: [Trainer] {
        if case .loaded(let trainers) = viewState { return trainers }
        return []
    }

    public var errorMessage: String? {
        if case .failure(let message) = viewState { return message }
        return nil
    }

    // MARK: - Dependencies
    private let searchUseCase: SearchTrainersUseCaseProtocol

    // MARK: - Private
    private var searchTask: Task<Void, Never>?

    // MARK: - Init
    public init(searchUseCase: SearchTrainersUseCaseProtocol) {
        self.searchUseCase = searchUseCase
    }

    // MARK: - Actions
    public func onAppear() async {
        await performSearch()
    }

    public func onQueryChanged() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    public func onCategorySelected(_ category: TrainingCategory) {
        selectedCategory = selectedCategory == category ? nil : category
        searchTask?.cancel()
        searchTask = Task {
            await performSearch()
        }
    }

    public func onRetry() async {
        viewState = .idle
        await performSearch()
    }

    // MARK: - Private
    private func performSearch() async {
        viewState = .loading

        do {
            let results = try await searchUseCase.execute(
                query: searchQuery,
                category: selectedCategory
            )
            viewState = results.isEmpty ? .empty : .loaded(results)
        } catch let error as TrainerError {
            viewState = .failure(error.localizedDescription)
        } catch {
            if !Task.isCancelled {
                viewState = .failure(error.localizedDescription)
            }
        }
    }
}
