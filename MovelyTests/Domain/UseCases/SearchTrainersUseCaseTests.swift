//
//  SearchTrainersUseCaseTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 05/04/26.
//

import Foundation
import Testing
@testable import Movely

// MARK: - SearchTrainers UseCase Tests
@Suite("SearchTrainersUseCase")
@MainActor
struct SearchTrainersUseCaseTests {

    // MARK: - Helpers
    func makeSUT(shouldFail: Bool = false) -> (
        sut: SearchTrainersUseCase,
        repository: TrainerRepositoryMock
    ) {
        let repository = TrainerRepositoryMock()
        repository.shouldFail = shouldFail
        repository.delay = 0
        let sut = SearchTrainersUseCase(repository: repository)
        return (sut, repository)
    }

    // MARK: - Query Tests
    @Suite("Query Search")
    @MainActor
    struct QueryTests {

        @Test("Empty query should return all trainers")
        func emptyQueryReturnsAll() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(query: "", category: nil)

            #expect(!results.isEmpty)
        }

        @Test("Query matching trainer name should return correct trainer")
        func queryByNameReturnsMatch() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(query: "Carlos", category: nil)

            #expect(results.contains { $0.name.contains("Carlos") })
        }

        @Test("Query matching specialty should return trainers with that specialty")
        func queryBySpecialtyReturnsMatch() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(query: "yoga", category: nil)

            #expect(results.allSatisfy { trainer in
                trainer.specialties.contains { $0.rawValue.lowercased().contains("yoga") }
            })
        }

        @Test("Query with no matches should return empty array")
        func queryWithNoMatchesReturnsEmpty() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(query: "xyzabc123", category: nil)

            #expect(results.isEmpty)
        }

        @Test("Query should be case insensitive")
        func queryIsCaseInsensitive() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let lowerResults = try await sut.execute(query: "carlos", category: nil)
            let upperResults = try await sut.execute(query: "CARLOS", category: nil)

            #expect(lowerResults.count == upperResults.count)
        }

        @Test("Query with only whitespace should return all trainers")
        func whitespaceQueryReturnsAll() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(query: "   ", category: nil)

            #expect(!results.isEmpty)
        }
    }

    // MARK: - Category Tests
    @Suite("Category Filter")
    @MainActor
    struct CategoryTests {

        @Test("Filtering by category should return only trainers with that specialty")
        func filterByCategoryReturnsMatch() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(query: "", category: .yoga)

            #expect(!results.isEmpty)
            #expect(results.allSatisfy { $0.specialties.contains(.yoga) })
        }

        @Test("Filtering by category with query should narrow results")
        func filterByCategoryAndQueryNarrowsResults() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let categoryResults = try await sut.execute(query: "", category: .strength)
            let narrowedResults = try await sut.execute(query: "Carlos", category: .strength)

            #expect(narrowedResults.count <= categoryResults.count)
        }

        @Test("Filtering by category with no matches should return empty array")
        func filterByCategoryNoMatchReturnsEmpty() async throws {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT()

            let results = try await sut.execute(query: "xyzabc", category: .yoga)

            #expect(results.isEmpty)
        }
    }

    // MARK: - Failure Tests
    @Suite("Failure")
    @MainActor
    struct FailureTests {

        @Test("Repository failure should propagate error")
        func repositoryFailurePropagates() async {
            let (sut, _) = SearchTrainersUseCaseTests().makeSUT(shouldFail: true)

            await #expect(throws: TrainerError.self) {
                try await sut.execute(query: "", category: nil)
            }
        }
    }
}
