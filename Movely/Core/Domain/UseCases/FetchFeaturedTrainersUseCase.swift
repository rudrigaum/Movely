//
//  FetchFeaturedTrainersUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 14/03/26.
//

import Foundation

// MARK: - Protocol
public protocol FetchFeaturedTrainersUseCaseProtocol {
    func execute() async throws -> [Trainer]
}

// MARK: - Use Case
public final class FetchFeaturedTrainersUseCase: FetchFeaturedTrainersUseCaseProtocol {

    private let repository: TrainerRepositoryProtocol

    public init(repository: TrainerRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Trainer] {
        try await repository.fetchFeatured()
    }
}

// MARK: - Mock
#if DEBUG
public final class FetchFeaturedTrainersUseCaseMock: FetchFeaturedTrainersUseCaseProtocol {
    public var shouldFail: Bool = false
    public var trainers: [Trainer] = Trainer.mockFeatured

    public init() {}

    public func execute() async throws -> [Trainer] {
        if shouldFail { throw TrainerError.networkError }
        return trainers
    }
}
#endif
