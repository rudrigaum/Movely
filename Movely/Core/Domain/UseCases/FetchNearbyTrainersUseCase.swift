//
//  FetchNearbyTrainersUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 14/03/26.
//

import Foundation

// MARK: - Protocol
public protocol FetchNearbyTrainersUseCaseProtocol {
    func execute(limit: Int) async throws -> [Trainer]
}

// MARK: - Use Case
public final class FetchNearbyTrainersUseCase: FetchNearbyTrainersUseCaseProtocol {

    private let repository: TrainerRepositoryProtocol

    public init(repository: TrainerRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(limit: Int = 4) async throws -> [Trainer] {
        try await repository.fetchNearby(limit: limit)
    }
}

// MARK: - Mock
#if DEBUG
public final class FetchNearbyTrainersUseCaseMock: FetchNearbyTrainersUseCaseProtocol {
    public var shouldFail: Bool = false
    public var trainers: [Trainer] = Trainer.mockNearby

    public init() {}

    public func execute(limit: Int = 4) async throws -> [Trainer] {
        if shouldFail { throw TrainerError.networkError }
        return Array(trainers.prefix(limit))
    }
}
#endif
