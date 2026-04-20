//
//  HomeViewModelTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 11/04/26.
//

import Foundation
import Testing
@testable import Movely

// MARK: - HomeViewModel Tests
@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    // MARK: - Helpers
    func makeSUT(
        featuredShouldFail: Bool = false,
        nearbyShouldFail: Bool = false
    ) -> HomeViewModel {
        let featuredUseCase = FetchFeaturedTrainersUseCaseMock()
        featuredUseCase.shouldFail = featuredShouldFail

        let nearbyUseCase = FetchNearbyTrainersUseCaseMock()
        nearbyUseCase.shouldFail = nearbyShouldFail

        return HomeViewModel(
            fetchFeaturedUseCase: featuredUseCase,
            fetchNearbyUseCase: nearbyUseCase
        )
    }

    // MARK: - Initial State Tests
    @Suite("Initial State")
    @MainActor
    struct InitialStateTests {

        @Test("Initial state should be idle")
        func initialStateIsIdle() {
            let sut = HomeViewModelTests().makeSUT()

            #expect(sut.viewState == .idle)
            #expect(sut.featuredTrainers.isEmpty)
            #expect(sut.nearbyTrainers.isEmpty)
            #expect(sut.selectedCategory == nil)
        }

        @Test("isLoading should be false initially")
        func isLoadingFalseInitially() {
            let sut = HomeViewModelTests().makeSUT()

            #expect(!sut.isLoading)
        }
    }

    // MARK: - onAppear Tests
    @Suite("onAppear")
    @MainActor
    struct OnAppearTests {

        @Test("onAppear should load featured and nearby trainers")
        func onAppearLoadsTrainers() async {
            let sut = HomeViewModelTests().makeSUT()

            await sut.onAppear()

            #expect(sut.viewState == .loaded)
            #expect(!sut.featuredTrainers.isEmpty)
            #expect(!sut.nearbyTrainers.isEmpty)
        }

        @Test("onAppear should only fetch once when called multiple times")
        func onAppearFetchesOnlyOnce() async {
            let sut = HomeViewModelTests().makeSUT()

            await sut.onAppear()
            let firstCount = sut.featuredTrainers.count

            await sut.onAppear()
            let secondCount = sut.featuredTrainers.count

            #expect(firstCount == secondCount)
        }

        @Test("onAppear should set loaded state on success")
        func onAppearSetsLoadedState() async {
            let sut = HomeViewModelTests().makeSUT()

            await sut.onAppear()

            #expect(sut.viewState == .loaded)
        }
    }

    // MARK: - onRefresh Tests
    @Suite("onRefresh")
    @MainActor
    struct OnRefreshTests {

        @Test("onRefresh should reload trainers regardless of current state")
        func onRefreshReloadsTrainers() async {
            let sut = HomeViewModelTests().makeSUT()

            await sut.onAppear()
            await sut.onRefresh()

            #expect(sut.viewState == .loaded)
            #expect(!sut.featuredTrainers.isEmpty)
        }
    }

    // MARK: - Category Tests
    @Suite("Category Selection")
    @MainActor
    struct CategoryTests {

        @Test("Selecting a category should update selectedCategory")
        func selectingCategoryUpdatesState() {
            let sut = HomeViewModelTests().makeSUT()

            sut.selectCategory(.yoga)

            #expect(sut.selectedCategory == .yoga)
        }

        @Test("Selecting same category twice should deselect it")
        func selectingSameCategoryDeselects() {
            let sut = HomeViewModelTests().makeSUT()

            sut.selectCategory(.yoga)
            sut.selectCategory(.yoga)

            #expect(sut.selectedCategory == nil)
        }

        @Test("Selecting different category should replace previous")
        func selectingDifferentCategoryReplaces() {
            let sut = HomeViewModelTests().makeSUT()

            sut.selectCategory(.yoga)
            sut.selectCategory(.strength)

            #expect(sut.selectedCategory == .strength)
        }
    }

    // MARK: - Failure Tests
    @Suite("Failure")
    @MainActor
    struct FailureTests {

        @Test("Featured usecase failure should set failure state")
        func featuredFailureSetsFailureState() async {
            let sut = HomeViewModelTests().makeSUT(featuredShouldFail: true)

            await sut.onAppear()

            if case .failure = sut.viewState {
                #expect(true)
            } else {
                #expect(Bool(false), "Expected failure state")
            }
        }

        @Test("Error message should not be nil on failure")
        func errorMessageNotNilOnFailure() async {
            let sut = HomeViewModelTests().makeSUT(featuredShouldFail: true)

            await sut.onAppear()

            #expect(sut.errorMessage != nil)
        }
    }
}
