//
//  CancelBookingUseCaseTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 09/09/26.
//

import Foundation
import Testing

@testable import Movely

// MARK: - Cancel Booking Use Case Tests
@Suite("CancelBookingUseCase Tests")
struct CancelBookingUseCaseTests {

    // MARK: - Execute
    @Test("Execute updates booking status to cancelled")
    func executeUpdatesBookingStatusToCancelled() async throws {
        let bookingId = "booking-123"
        let (sut, repository) = makeSUT()

        try await sut.execute(
            bookingId: bookingId
        )

        #expect(repository.updateBookingStatusCallCount == 1)
        #expect(repository.receivedBookingId == bookingId)

        guard let status = repository.receivedStatus else {
            Issue.record("Expected a booking status")
            return
        }

        switch status {
        case .cancelled:
            break

        default:
            Issue.record("Expected booking status to be cancelled")
        }
    }

    @Test("Execute propagates repository update failure")
    func executePropagatesRepositoryFailure() async {
        let expectedError = BookingError.updateFailed
        let (sut, repository) = makeSUT(
            errorToThrow: expectedError
        )

        do {
            try await sut.execute(
                bookingId: "booking-123"
            )

            Issue.record(
                "Expected execute to throw an error"
            )
        } catch let error as BookingError {
            switch error {
            case .updateFailed:
                break

            default:
                Issue.record(
                    "Expected BookingError.updateFailed"
                )
            }
        } catch {
            Issue.record(
                "Expected BookingError but received \(error)"
            )
        }

        #expect(repository.updateBookingStatusCallCount == 1)
    }

    // MARK: - Factory
    private func makeSUT(
        errorToThrow: Error? = nil
    ) -> (
        sut: CancelBookingUseCase,
        repository: BookingRepositorySpy
    ) {
        let repository = BookingRepositorySpy(
            errorToThrow: errorToThrow
        )

        let sut = CancelBookingUseCase(
            repository: repository
        )

        return (
            sut,
            repository
        )
    }

}

// MARK: - Booking Repository Spy
private final class BookingRepositorySpy:
    BookingRepositoryProtocol {

    // MARK: - Properties
    private(set) var updateBookingStatusCallCount = 0
    private(set) var receivedBookingId: String?
    private(set) var receivedStatus: BookingStatus?

    private let errorToThrow: Error?

    // MARK: - Initialization
    init(
        errorToThrow: Error? = nil
    ) {
        self.errorToThrow = errorToThrow
    }

    // MARK: - Booking Repository Protocol
    func createBooking(
        _ booking: Booking
    ) async throws {}

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
    ) async throws {
        updateBookingStatusCallCount += 1
        receivedBookingId = bookingId
        receivedStatus = status

        if let errorToThrow {
            throw errorToThrow
        }
    }

}
