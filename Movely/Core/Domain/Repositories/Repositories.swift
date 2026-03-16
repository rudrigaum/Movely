//
//  Repositories.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 14/03/26.
//

import Foundation

// MARK: - Trainer Repository Protocol
public protocol TrainerRepositoryProtocol {
    func fetchFeatured() async throws -> [Trainer]
    func fetchNearby(limit: Int) async throws -> [Trainer]
    func fetchByCategory(_ category: TrainingCategory) async throws -> [Trainer]
    func fetchById(_ id: String) async throws -> Trainer
}

// MARK: - Trainer Error
public enum TrainerError: LocalizedError {
    case notFound
    case networkError
    case unknown(message: String)

    public var errorDescription: String? {
        switch self {
        case .notFound: return "Trainer not found."
        case .networkError: return "Network error. Please try again."
        case .unknown(let message): return message
        }
    }
}

// MARK: - Mock
#if DEBUG
public final class TrainerRepositoryMock: TrainerRepositoryProtocol {

    // MARK: - Properties
    public var shouldFail: Bool = false
    public var delay: UInt64 = 800_000_000

    public init() {}

    // MARK: - Protocol
    public func fetchFeatured() async throws -> [Trainer] {
        try await simulate()
        return Trainer.mockFeatured
    }

    public func fetchNearby(limit: Int) async throws -> [Trainer] {
        try await simulate()
        return Array(Trainer.mockNearby.prefix(limit))
    }

    public func fetchByCategory(_ category: TrainingCategory) async throws -> [Trainer] {
        try await simulate()
        return Trainer.mockList.filter { $0.specialties.contains(category) }
    }

    public func fetchById(_ id: String) async throws -> Trainer {
        try await simulate()
        guard let trainer = Trainer.mockList.first(where: { $0.id == id }) else {
            throw TrainerError.notFound
        }
        return trainer
    }

    // MARK: - Private
    private func simulate() async throws {
        try await Task.sleep(nanoseconds: delay)
        if shouldFail { throw TrainerError.networkError }
    }
}
#endif
