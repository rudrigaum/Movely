//
//  BookingsViewModelTestDoubles.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 10/09/26.
//

import Foundation

@testable import Movely

// MARK: - Fetch Student Bookings Use Case Stub
final class FetchStudentBookingsUseCaseStub:
    FetchStudentBookingsUseCaseProtocol {

    // MARK: - Properties
    private(set) var executeCallCount = 0
    private(set) var receivedStudentId: String?

    private let results: [[Booking]]
    private let errorToThrow: Error?

    // MARK: - Initialization
    init(
        results: [[Booking]],
        errorToThrow: Error? = nil
    ) {
        self.results = results
        self.errorToThrow = errorToThrow
    }

    // MARK: - Execution
    func execute(
        studentId: String
    ) async throws -> [Booking] {
        executeCallCount += 1
        receivedStudentId = studentId

        if let errorToThrow {
            throw errorToThrow
        }

        guard !results.isEmpty else {
            return []
        }

        let index = min(
            executeCallCount - 1,
            results.count - 1
        )

        return results[index]
    }

}

// MARK: - Cancel Booking Use Case Spy
final class CancelBookingUseCaseSpy:
    CancelBookingUseCaseProtocol {

    // MARK: - Properties
    private(set) var executeCallCount = 0
    private(set) var receivedBookingId: String?

    private let errorToThrow: Error?

    // MARK: - Initialization
    init(
        errorToThrow: Error? = nil
    ) {
        self.errorToThrow = errorToThrow
    }

    // MARK: - Execution
    func execute(
        bookingId: String
    ) async throws {
        executeCallCount += 1
        receivedBookingId = bookingId

        if let errorToThrow {
            throw errorToThrow
        }
    }

}
