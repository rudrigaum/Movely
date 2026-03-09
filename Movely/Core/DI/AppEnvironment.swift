//
//  AppEnvironment.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation
import SwiftUI

// MARK: - App Environment
@Observable
public final class AppEnvironment {

    // MARK: - Auth
    public let authRepository: AuthRepositoryProtocol
    public let signInUseCase: SignInUseCaseProtocol
    public let signUpUseCase: SignUpUseCaseProtocol

    // MARK: - Session
    public var currentUser: User?
    public var isAuthenticated: Bool { currentUser != nil }

    // MARK: - Init
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        self.signInUseCase = SignInUseCase(repository: authRepository)
        self.signUpUseCase = SignUpUseCase(repository: authRepository)
        self.currentUser = authRepository.currentUser
    }
}

// MARK: - Production Environment
public extension AppEnvironment {
    static func production() -> AppEnvironment {
        AppEnvironment(authRepository: AuthRepository())
    }
}

// MARK: - Mock Environment
#if DEBUG
public extension AppEnvironment {
    static func mock(
        isAuthenticated: Bool = false,
        shouldFail: Bool = false
    ) -> AppEnvironment {
        let repository = AuthRepositoryMock()
        repository.shouldFail = shouldFail
        if isAuthenticated {
            repository.currentUser = .mockStudent
        }
        let env = AppEnvironment(authRepository: repository)
        env.currentUser = repository.currentUser
        return env
    }

    static var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] != nil
    }

    static func resolved() -> AppEnvironment {
        isRunningInPreview ? .mock() : .production()
    }
}
#endif
