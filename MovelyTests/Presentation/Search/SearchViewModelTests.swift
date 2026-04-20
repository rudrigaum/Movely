//
//  SearchViewModelTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 11/04/26.
//

import Foundation
import Testing
@testable import Movely

// MARK: - SearchViewModel Tests
@Suite("SearchViewModel")
@MainActor
struct SearchViewModelTests {

    // MARK: - Helpers
    func makeSUT(shouldFail: Bool = false) -> (
        sut: SearchViewModel,
        useCase: SearchTrainersUseCaseMock
    ) {
        let useCase = SearchTrainersUseCaseMock()
        useCase.shouldFail = shouldFail
        let sut = SearchViewModel(searchUseCase: useCase)
        return (sut, useCase)
    }

    // MARK: - Initial State Tests
    @Suite("Initial State")
    @MainActor
    struct InitialStateTests {

        @Test("Initial state should be idle")
        func initialStateIsIdle() {
            let (sut, _) = SearchViewModelTests().makeSUT()

            #expect(sut.viewState == .idle)
            #expect(sut.searchQuery.isEmpty)
            #expect(sut.selectedCategory == nil)
            #expect(sut.trainers.isEmpty)
        }

        @Test("isLoading should be false initially")
        func isLoadingFalseInitially() {
            let (sut, _) = SearchViewModelTests().makeSUT()

            #expect(!sut.isLoading)
        }
    }

    // MARK: - onAppear Tests
    @Suite("onAppear")
    @MainActor
    struct OnAppearTests {

        @Test("onAppear should load trainers")
        func onAppearLoadsTrainers() async {
            let (sut, _) = SearchViewModelTests().makeSUT()

            await sut.onAppear()

            #expect(!sut.trainers.isEmpty)
        }

        @Test("onAppear with results should set loaded state")
        func onAppearSetsLoadedState() async {
            let (sut, _) = SearchViewModelTests().makeSUT()

            await sut.onAppear()

            if case .loaded = sut.viewState {
                #expect(true)
            } else {
                #expect(Bool(false), "Expected loaded state")
            }
        }
    }

    // MARK: - Category Tests
    @Suite("Category Selection")
    @MainActor
    struct CategoryTests {

        @Test("Selecting a category should update selectedCategory")
        func selectingCategoryUpdatesState() async {
            let (sut, _) = SearchViewModelTests().makeSUT()

            sut.onCategorySelected(.yoga)
            await sut.onAppear()

            #expect(sut.selectedCategory == .yoga)
        }

        @Test("Selecting same category twice should deselect it")
        func selectingSameCategoryDeselects() async {
            let (sut, _) = SearchViewModelTests().makeSUT()

            sut.onCategorySelected(.yoga)
            sut.onCategorySelected(.yoga)

            #expect(sut.selectedCategory == nil)
        }

        @Test("Selecting different category should replace previous")
        func selectingDifferentCategoryReplaces() async {
            let (sut, _) = SearchViewModelTests().makeSUT()

            sut.onCategorySelected(.yoga)
            sut.onCategorySelected(.strength)

            #expect(sut.selectedCategory == .strength)
        }
    }

    // MARK: - Empty State Tests
    @Suite("Empty State")
    @MainActor
    struct EmptyStateTests {

        @Test("Search with no results should set empty state")
        func noResultsSetsEmptyState() async {
            let (sut, useCase) = SearchViewModelTests().makeSUT()
            useCase.returnedTrainers = []

            await sut.onAppear()

            #expect(sut.viewState == .empty)
        }

        @Test("Trainers should be empty on empty state")
        func trainersEmptyOnEmptyState() async {
            let (sut, useCase) = SearchViewModelTests().makeSUT()
            useCase.returnedTrainers = []

            await sut.onAppear()

            #expect(sut.trainers.isEmpty)
        }
    }

    // MARK: - Failure Tests
    @Suite("Failure")
    @MainActor
    struct FailureTests {

        @Test("UseCase failure should set failure state")
        func useCaseFailureSetsFailureState() async {
            let (sut, _) = SearchViewModelTests().makeSUT(shouldFail: true)

            await sut.onAppear()

            if case .failure = sut.viewState {
                #expect(true)
            } else {
                #expect(Bool(false), "Expected failure state")
            }
        }

        @Test("Error message should not be nil on failure")
        func errorMessageNotNilOnFailure() async {
            let (sut, _) = SearchViewModelTests().makeSUT(shouldFail: true)

            await sut.onAppear()

            #expect(sut.errorMessage != nil)
        }

        @Test("onRetry should reset and reload")
        func onRetryResetsAndReloads() async {
            let (sut, useCase) = SearchViewModelTests().makeSUT(shouldFail: true)

            await sut.onAppear()
            useCase.shouldFail = false
            await sut.onRetry()

            if case .loaded = sut.viewState {
                #expect(true)
            } else {
                #expect(Bool(false), "Expected loaded state after retry")
            }
        }
    }
}
