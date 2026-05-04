//
//  UserRepositoryProtocol.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 20/04/26.
//

import Foundation

// MARK: - User Repository Protocol
public protocol UserRepositoryProtocol {
    func fetchCurrentUser() async throws -> User
    func updateName(_ name: String) async throws -> User
}

// MARK: - User Error
public enum UserError: LocalizedError, Equatable {
    case notFound
    case updateFailed
    case networkError
    case unknown(message: String)

    public var errorDescription: String? {
        switch self {
        case .notFound: return "User not found."
        case .updateFailed: return "Failed to update profile. Please try again."
        case .networkError: return "Network error. Please try again."
        case .unknown(let message): return message
        }
    }
}

// MARK: - Mock
#if DEBUG
public final class UserRepositoryMock: UserRepositoryProtocol {

    // MARK: - Properties
    public var shouldFail: Bool = false
    public var currentUser: User = .mockStudent
    public var delay: UInt64 = 500_000_000 // 0.5s

    public init() {}

    // MARK: - Protocol
    public func fetchCurrentUser() async throws -> User {
        try await simulate()
        return currentUser
    }

    public func updateName(_ name: String) async throws -> User {
        try await simulate()
        currentUser = User(
            id: currentUser.id,
            name: name,
            email: currentUser.email,
            role: currentUser.role,
            avatarURL: currentUser.avatarURL,
            createdAt: currentUser.createdAt
        )
        return currentUser
    }

    // MARK: - Private
    private func simulate() async throws {
        try await Task.sleep(nanoseconds: delay)
        if shouldFail { throw UserError.networkError }
    }
}
#endif
