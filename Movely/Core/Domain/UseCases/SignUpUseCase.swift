//
//  SignUpUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation

// MARK: - SignUp UseCase Protocol
public protocol SignUpUseCaseProtocol {
    func execute(name: String, email: String, password: String, role: UserRole) async throws -> User
}

// MARK: - SignUp UseCase
public final class SignUpUseCase: SignUpUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: AuthRepositoryProtocol

    // MARK: - Init
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    public func execute(
        name: String,
        email: String,
        password: String,
        role: UserRole
    ) async throws -> User {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard Validators.isValidName(trimmedName) else {
            throw AuthError.unknown(message: "Name must be at least 2 characters.")
        }

        guard Validators.isValidEmail(trimmedEmail) else {
            throw AuthError.invalidEmail
        }

        guard Validators.isValidPassword(trimmedPassword) else {
            throw AuthError.weakPassword
        }

        return try await repository.signUp(
            name: trimmedName,
            email: trimmedEmail,
            password: trimmedPassword,
            role: role
        )
    }
}

// MARK: - Mock
#if DEBUG
final class SignUpUseCaseMock: SignUpUseCaseProtocol {
    var shouldFail = false
    var returnedUser: User = .mockStudent

    func execute(
        name: String,
        email: String,
        password: String,
        role: UserRole
    ) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if shouldFail { throw AuthError.emailAlreadyInUse }
        return User(
            id: "new-user-001",
            name: name,
            email: email,
            role: role
        )
    }
}
#endif
