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

    // MARK: - User
    public let userRepository: UserRepositoryProtocol
    public let updateUserUseCase: UpdateUserUseCaseProtocol

    // MARK: - Trainer
    public let trainerRepository: TrainerRepositoryProtocol
    public let fetchFeaturedUseCase: FetchFeaturedTrainersUseCaseProtocol
    public let fetchNearbyUseCase: FetchNearbyTrainersUseCaseProtocol
    public let searchTrainersUseCase: SearchTrainersUseCaseProtocol

    // MARK: - Booking
    public let bookingRepository: BookingRepositoryProtocol
    public let createBookingUseCase: CreateBookingUseCase

    // MARK: - Session
    public var currentUser: User?
    public var isAuthenticated: Bool { currentUser != nil }

    // MARK: - Init
    public init(
        authRepository: AuthRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        trainerRepository: TrainerRepositoryProtocol,
        bookingRepository: BookingRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.trainerRepository = trainerRepository
        self.bookingRepository = bookingRepository

        self.signInUseCase = SignInUseCase(repository: authRepository)
        self.signUpUseCase = SignUpUseCase(repository: authRepository)
        self.updateUserUseCase = UpdateUserUseCase(repository: userRepository)
        self.fetchFeaturedUseCase = FetchFeaturedTrainersUseCase(repository: trainerRepository)
        self.fetchNearbyUseCase = FetchNearbyTrainersUseCase(repository: trainerRepository)
        self.searchTrainersUseCase = SearchTrainersUseCase(repository: trainerRepository)

        self.createBookingUseCase = CreateBookingUseCase(repository: bookingRepository)

        self.currentUser = authRepository.currentUser
    }
}

// MARK: - Production Environment
public extension AppEnvironment {
    static func production() -> AppEnvironment {
        AppEnvironment(
            authRepository: AuthRepository(),
            userRepository: UserRepository(),
            trainerRepository: TrainerRepository(),
            bookingRepository: BookingRepository()
        )
    }
}

// MARK: - Mock Environment
#if DEBUG
public extension AppEnvironment {
    static func mock(
        isAuthenticated: Bool = false,
        shouldFail: Bool = false
    ) -> AppEnvironment {
        let authRepository = AuthRepositoryMock()
        authRepository.shouldFail = shouldFail
        if isAuthenticated {
            authRepository.currentUser = .mockStudent
        }

        let userRepository = UserRepositoryMock()
        userRepository.shouldFail = shouldFail

        let trainerRepository = TrainerRepositoryMock()
        trainerRepository.shouldFail = shouldFail
        trainerRepository.delay = 0

        let bookingRepository = BookingRepositoryMock()
        bookingRepository.shouldThrowError = shouldFail

        let env = AppEnvironment(
            authRepository: authRepository,
            userRepository: userRepository,
            trainerRepository: trainerRepository,
            bookingRepository: bookingRepository
        )
        env.currentUser = authRepository.currentUser
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
