//
//  FetchFeaturedTrainersUseCaseTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 07/04/26.
//

import Foundation
import Testing
@testable import Movely

// MARK: - FetchFeaturedTrainers UseCase Tests
@Suite("FetchFeaturedTrainersUseCase")
@MainActor
struct FetchFeaturedTrainersUseCaseTests {

    // MARK: - Helpers
    func makeSUT(shouldFail: Bool = false) -> (
        sut: FetchFeaturedTrainersUseCase,
        repository: TrainerRepositoryMock
    ) {
        let repository = TrainerRepositoryMock()
        repository.shouldFail = shouldFail
        repository.delay = 0
        let sut = FetchFeaturedTrainersUseCase(repository: repository)
        return (sut, repository)
    }

    // MARK: - Success Tests
    @Suite("Success")
    @MainActor
    struct SuccessTests {

        @Test("Should return only featured trainers")
        func returnsOnlyFeaturedTrainers() async throws {
            let (sut, _) = FetchFeaturedTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute()

            #expect(!results.isEmpty)
            #expect(results.allSatisfy { $0.isFeatured })
        }

        @Test("Should return correct number of featured trainers")
        func returnsCorrectCount() async throws {
            let (sut, _) = FetchFeaturedTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute()

            #expect(results.count == Trainer.mockFeatured.count)
        }

        @Test("Returned trainers should have valid data")
        func returnedTrainersHaveValidData() async throws {
            let (sut, _) = FetchFeaturedTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute()

            for trainer in results {
                #expect(!trainer.id.isEmpty)
                #expect(!trainer.name.isEmpty)
                #expect(trainer.rating >= 0 && trainer.rating <= 5)
                #expect(trainer.hourlyRate > 0)
            }
        }
    }

    // MARK: - Failure Tests
    @Suite("Failure")
    @MainActor
    struct FailureTests {

        @Test("Repository failure should propagate error")
        func repositoryFailurePropagates() async {
            let (sut, _) = FetchFeaturedTrainersUseCaseTests().makeSUT(shouldFail: true)

            await #expect(throws: TrainerError.self) {
                try await sut.execute()
            }
        }
    }
}
