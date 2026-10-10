//
//  CreateBookingUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/06/26.
//

import Foundation

// MARK: - Use Case Errors

public enum CreateBookingError: LocalizedError {

    case pastDateNotAllowed
    case invalidDuration
    case trainerUnavailable

    public var errorDescription: String? {
        switch self {
        case .pastDateNotAllowed:
            return "The booking date cannot be in the past."

        case .invalidDuration:
            return "The booking duration must be greater than zero."

        case .trainerUnavailable:
            return "This trainer is currently unavailable for bookings."
        }
    }

}

// MARK: - Use Case

public struct CreateBookingUseCase {

    // MARK: - Dependencies

    private let bookingRepository: BookingRepositoryProtocol
    private let trainerRepository: TrainerRepositoryProtocol

    // MARK: - Initialization

    public init(
        bookingRepository: BookingRepositoryProtocol,
        trainerRepository: TrainerRepositoryProtocol
    ) {
        self.bookingRepository = bookingRepository
        self.trainerRepository = trainerRepository
    }

    // MARK: - Execution

    public func execute(
        studentId: String,
        trainerId: String,
        date: Date,
        durationInMinutes: Int = 60,
        notes: String? = nil
    ) async throws {
        guard date > Date() else {
            throw CreateBookingError.pastDateNotAllowed
        }

        guard durationInMinutes > 0 else {
            throw CreateBookingError.invalidDuration
        }

        let trainer = try await trainerRepository.fetchById(
            trainerId
        )

        guard trainer.isAvailable else {
            throw CreateBookingError.trainerUnavailable
        }

        let booking = Booking(
            studentId: studentId,
            trainerId: trainerId,
            date: date,
            durationInMinutes: durationInMinutes,
            status: .pending,
            notes: notes
        )

        try await bookingRepository.createBooking(
            booking
        )
    }

}
