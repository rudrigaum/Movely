//
//  FetchNearbyTrainersUseCaseTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 11/04/26.
//

import Foundation
import Testing
@testable import Movely

// MARK: - FetchNearbyTrainers UseCase Tests
@Suite("FetchNearbyTrainersUseCase")
@MainActor
struct FetchNearbyTrainersUseCaseTests {

    // MARK: - Helpers
    func makeSUT(shouldFail: Bool = false) -> (
        sut: FetchNearbyTrainersUseCase,
        repository: TrainerRepositoryMock
    ) {
        let repository = TrainerRepositoryMock()
        repository.shouldFail = shouldFail
        repository.delay = 0
        let sut = FetchNearbyTrainersUseCase(repository: repository)
        return (sut, repository)
    }

    // MARK: - Success Tests
    @Suite("Success")
    @MainActor
    struct SuccessTests {

        @Test("Should return trainers up to the requested limit")
        func returnsUpToLimit() async throws {
            let (sut, _) = FetchNearbyTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(limit: 2)

            #expect(results.count <= 2)
        }

        @Test("Should return all trainers when limit exceeds total")
        func returnsAllWhenLimitExceedsTotal() async throws {
            let (sut, _) = FetchNearbyTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(limit: 100)

            #expect(results.count == Trainer.mockNearby.count)
        }

        @Test("Default limit of 4 should return at most 4 trainers")
        func defaultLimitReturnsFour() async throws {
            let (sut, _) = FetchNearbyTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(limit: 4)

            #expect(results.count <= 4)
        }

        @Test("Returned trainers should have valid location data")
        func returnedTrainersHaveValidLocation() async throws {
            let (sut, _) = FetchNearbyTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(limit: 10)

            for trainer in results {
                #expect(!trainer.location.city.isEmpty)
                #expect(!trainer.location.state.isEmpty)
            }
        }

        @Test("Should return trainers sorted by distance")
        func returnedTrainersSortedByDistance() async throws {
            let (sut, _) = FetchNearbyTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(limit: 10)
            let distances = results.compactMap { $0.location.distanceKm }

            let isSorted = zip(distances, distances.dropFirst()).allSatisfy { $0 <= $1 }
            #expect(isSorted)
        }
    }

    // MARK: - Failure Tests
    @Suite("Failure")
    @MainActor
    struct FailureTests {

        @Test("Repository failure should propagate error")
        func repositoryFailurePropagates() async {
            let (sut, _) = FetchNearbyTrainersUseCaseTests().makeSUT(shouldFail: true)

            await #expect(throws: TrainerError.self) {
                try await sut.execute(limit: 4)
            }
        }
    }
}
