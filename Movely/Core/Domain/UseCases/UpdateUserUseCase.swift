//
//  UpdateUserUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 20/04/26.
//

import Foundation

// MARK: - Protocol
public protocol UpdateUserUseCaseProtocol {
    func execute(name: String) async throws -> User
}

// MARK: - Use Case
public final class UpdateUserUseCase: UpdateUserUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: UserRepositoryProtocol

    // MARK: - Init
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    public func execute(name: String) async throws -> User {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard Validators.isValidName(trimmedName) else {
            throw UserError.updateFailed
        }

        return try await repository.updateName(trimmedName)
    }
}

// MARK: - Mock
#if DEBUG
public final class UpdateUserUseCaseMock: UpdateUserUseCaseProtocol {

    public var shouldFail: Bool = false
    public var updatedUser: User = .mockStudent

    public init() {}

    public func execute(name: String) async throws -> User {
        try await Task.sleep(nanoseconds: 300_000_000)
        if shouldFail { throw UserError.updateFailed }
        updatedUser = User(
            id: updatedUser.id,
            name: name,
            email: updatedUser.email,
            role: updatedUser.role,
            avatarURL: updatedUser.avatarURL,
            createdAt: updatedUser.createdAt
        )
        return updatedUser
    }
}
#endif
