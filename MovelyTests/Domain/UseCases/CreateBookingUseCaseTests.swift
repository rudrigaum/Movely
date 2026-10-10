//
//  CreateBookingUseCaseTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 08/10/26.
//

import Foundation
import Testing

@testable import Movely

// MARK: - Create Booking Use Case Tests

@Suite("CreateBookingUseCase Tests")
@MainActor
struct CreateBookingUseCaseTests {

    // MARK: - Success

    @Test("Creates a pending booking when trainer is available")
    func createsBookingWhenTrainerIsAvailable() async throws {
        let context = makeSUT()
        let date = Date().addingTimeInterval(86_400)

        try await context.sut.execute(
            studentId: "student-123",
            trainerId: "trainer-123",
            date: date,
            durationInMinutes: 60,
            notes: "Strength training"
        )

        #expect(context.trainerRepository.fetchByIdCallCount == 1)
        #expect(context.trainerRepository.receivedTrainerId == "trainer-123")
        #expect(context.bookingRepository.createdBookings.count == 1)

        guard let booking = context.bookingRepository.createdBookings.first else {
            Issue.record("Expected a booking to be created")
            return
        }

        #expect(booking.studentId == "student-123")
        #expect(booking.trainerId == "trainer-123")
        #expect(booking.date == date)
        #expect(booking.durationInMinutes == 60)
        #expect(booking.status == .pending)
        #expect(booking.notes == "Strength training")
    }

    // MARK: - Availability

    @Test("Rejects booking when trainer is unavailable")
    func rejectsUnavailableTrainer() async {
        let context = makeSUT(
            trainer: Trainer.mockList[2]
        )

        do {
            try await context.sut.execute(
                studentId: "student-123",
                trainerId: "trainer-123",
                date: Date().addingTimeInterval(86_400)
            )

            Issue.record("Expected trainerUnavailable error")
        } catch CreateBookingError.trainerUnavailable {
            // Expected error.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(context.trainerRepository.fetchByIdCallCount == 1)
        #expect(context.bookingRepository.createdBookings.isEmpty)
    }

    // MARK: - Date Validation

    @Test("Rejects booking with a past date")
    func rejectsPastDate() async {
        let context = makeSUT()

        do {
            try await context.sut.execute(
                studentId: "student-123",
                trainerId: "trainer-123",
                date: Date().addingTimeInterval(-3_600)
            )

            Issue.record("Expected pastDateNotAllowed error")
        } catch CreateBookingError.pastDateNotAllowed {
            // Expected error.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(context.trainerRepository.fetchByIdCallCount == 0)
        #expect(context.bookingRepository.createdBookings.isEmpty)
    }

    // MARK: - Duration Validation

    @Test("Rejects booking with invalid duration")
    func rejectsInvalidDuration() async {
        let context = makeSUT()

        do {
            try await context.sut.execute(
                studentId: "student-123",
                trainerId: "trainer-123",
                date: Date().addingTimeInterval(86_400),
                durationInMinutes: 0
            )

            Issue.record("Expected invalidDuration error")
        } catch CreateBookingError.invalidDuration {
            // Expected error.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(context.trainerRepository.fetchByIdCallCount == 0)
        #expect(context.bookingRepository.createdBookings.isEmpty)
    }

    // MARK: - Repository Failures

    @Test("Propagates trainer repository failure")
    func propagatesTrainerRepositoryFailure() async {
        let context = makeSUT(
            trainerError: TrainerError.networkError
        )

        do {
            try await context.sut.execute(
                studentId: "student-123",
                trainerId: "trainer-123",
                date: Date().addingTimeInterval(86_400)
            )

            Issue.record("Expected trainer repository failure")
        } catch TrainerError.networkError {
            // Expected error.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(context.trainerRepository.fetchByIdCallCount == 1)
        #expect(context.bookingRepository.createdBookings.isEmpty)
    }

    @Test("Propagates booking repository failure")
    func propagatesBookingRepositoryFailure() async {
        let context = makeSUT(
            bookingError: BookingError.createFailed
        )

        do {
            try await context.sut.execute(
                studentId: "student-123",
                trainerId: "trainer-123",
                date: Date().addingTimeInterval(86_400)
            )

            Issue.record("Expected booking repository failure")
        } catch BookingError.createFailed {
            // Expected error.
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(context.trainerRepository.fetchByIdCallCount == 1)
        #expect(context.bookingRepository.createCallCount == 1)
    }

    // MARK: - Test Context

    private struct TestContext {
        let sut: CreateBookingUseCase
        let trainerRepository: CreateBookingTrainerRepositorySpy
        let bookingRepository: CreateBookingRepositorySpy
    }

    // MARK: - Factory

    private func makeSUT(
        trainer: Trainer? = nil,
        trainerError: Error? = nil,
        bookingError: Error? = nil
    ) -> TestContext {
        let resolvedTrainer = trainer ?? Trainer.mockList[0]

        let trainerRepository = CreateBookingTrainerRepositorySpy(
            trainer: resolvedTrainer,
            errorToThrow: trainerError
        )

        let bookingRepository = CreateBookingRepositorySpy(
            errorToThrow: bookingError
        )

        let sut = CreateBookingUseCase(
            bookingRepository: bookingRepository,
            trainerRepository: trainerRepository
        )

        return TestContext(
            sut: sut,
            trainerRepository: trainerRepository,
            bookingRepository: bookingRepository
        )
    }
}

// MARK: - Trainer Repository Spy

private final class CreateBookingTrainerRepositorySpy:
    TrainerRepositoryProtocol {

    private(set) var fetchByIdCallCount = 0
    private(set) var receivedTrainerId: String?

    private let trainer: Trainer
    private let errorToThrow: Error?

    init(
        trainer: Trainer,
        errorToThrow: Error? = nil
    ) {
        self.trainer = trainer
        self.errorToThrow = errorToThrow
    }

    func fetchFeatured() async throws -> [Trainer] {
        []
    }

    func fetchNearby(limit: Int) async throws -> [Trainer] {
        []
    }

    func fetchByCategory(
        _ category: TrainingCategory
    ) async throws -> [Trainer] {
        []
    }

    func fetchById(_ id: String) async throws -> Trainer {
        fetchByIdCallCount += 1
        receivedTrainerId = id

        if let errorToThrow {
            throw errorToThrow
        }

        return trainer
    }
}

// MARK: - Booking Repository Spy

private final class CreateBookingRepositorySpy:
    BookingRepositoryProtocol {

    private(set) var createCallCount = 0
    private(set) var createdBookings: [Booking] = []

    private let errorToThrow: Error?

    init(errorToThrow: Error? = nil) {
        self.errorToThrow = errorToThrow
    }

    func createBooking(_ booking: Booking) async throws {
        createCallCount += 1

        if let errorToThrow {
            throw errorToThrow
        }

        createdBookings.append(booking)
    }

    func fetchStudentBookings(
        studentId: String
    ) async throws -> [Booking] {
        []
    }

    func fetchTrainerBookings(
        trainerId: String
    ) async throws -> [Booking] {
        []
    }

    func updateBookingStatus(
        bookingId: String,
        status: BookingStatus
    ) async throws {}
}
