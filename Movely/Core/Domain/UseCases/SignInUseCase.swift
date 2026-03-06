//
//  SignInUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation

// MARK: - SignIn UseCase Protocol
public protocol SignInUseCaseProtocol {
    func execute(email: String, password: String) async throws -> User
}

// MARK: - SignIn UseCase
public final class SignInUseCase: SignInUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: AuthRepositoryProtocol

    // MARK: - Init
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    public func execute(email: String, password: String) async throws -> User {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard Validators.isValidEmail(trimmedEmail) else {
            throw AuthError.invalidEmail
        }

        guard !trimmedPassword.isEmpty else {
            throw AuthError.weakPassword
        }

        return try await repository.signIn(
            email: trimmedEmail,
            password: trimmedPassword
        )
    }

}

// MARK: - Mock
#if DEBUG
final class SignInUseCaseMock: SignInUseCaseProtocol {
    var shouldFail = false
    var returnedUser: User = .mockStudent

    func execute(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if shouldFail { throw AuthError.wrongPassword }
        return returnedUser
    }
}
#endif
