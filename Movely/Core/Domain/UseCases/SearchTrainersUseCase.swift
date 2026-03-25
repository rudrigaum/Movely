//
//  SearchTrainersUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 22/03/26.
//

import Foundation

// MARK: - Protocol
public protocol SearchTrainersUseCaseProtocol {
    func execute(query: String, category: TrainingCategory?) async throws -> [Trainer]
}

// MARK: - Use Case
public final class SearchTrainersUseCase: SearchTrainersUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: TrainerRepositoryProtocol

    // MARK: - Init
    public init(repository: TrainerRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    public func execute(query: String, category: TrainingCategory?) async throws -> [Trainer] {
        let trainers: [Trainer]

        if let category {
            trainers = try await repository.fetchByCategory(category)
        } else {
            trainers = try await repository.fetchNearby(limit: 20)
        }

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return trainers
        }

        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)

        return trainers.filter { trainer in
            trainer.name.lowercased().contains(normalizedQuery) ||
            trainer.specialties.map { $0.rawValue.lowercased() }.contains(where: { $0.contains(normalizedQuery) }) ||
            trainer.location.city.lowercased().contains(normalizedQuery)
        }
    }
}

// MARK: - Mock
#if DEBUG
public final class SearchTrainersUseCaseMock: SearchTrainersUseCaseProtocol {

    public var shouldFail: Bool = false
    public var returnedTrainers: [Trainer] = Trainer.mockList

    public init() {}

    public func execute(query: String, category: TrainingCategory?) async throws -> [Trainer] {
        try await Task.sleep(nanoseconds: 500_000_000)
        if shouldFail { throw TrainerError.networkError }

        let trainers = category == nil
            ? returnedTrainers
            : returnedTrainers.filter { $0.specialties.contains(category!) }

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return trainers
        }

        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)

        return trainers.filter {
            $0.name.lowercased().contains(normalizedQuery)
        }
    }
}
#endif
