//
//  BookingRepositoryProtocol.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/06/26.
//

import Foundation

// MARK: - Booking Error
public enum BookingError: LocalizedError {
    case fetchFailed
    case createFailed
    case updateFailed
    case notFound

    public var errorDescription: String? {
        switch self {
        case .fetchFailed: return "Failed to fetch bookings. Please try again."
        case .createFailed: return "Failed to create the booking."
        case .updateFailed: return "Failed to update the booking status."
        case .notFound: return "Booking not found."
        }
    }
}

// MARK: - Booking Repository Protocol
public protocol BookingRepositoryProtocol {
    func createBooking(_ booking: Booking) async throws
    func fetchStudentBookings(studentId: String) async throws -> [Booking]
    func fetchTrainerBookings(trainerId: String) async throws -> [Booking]
    func updateBookingStatus(bookingId: String, status: BookingStatus) async throws
}

// MARK: - Mock Implementation
#if DEBUG
public final class BookingRepositoryMock: BookingRepositoryProtocol {
    public var mockBookings: [Booking] = [.mock]
    public var shouldThrowError = false

    public init() {}

    public func createBooking(_ booking: Booking) async throws {
        if shouldThrowError { throw BookingError.createFailed }
        mockBookings.append(booking)
    }

    public func fetchStudentBookings(studentId: String) async throws -> [Booking] {
        if shouldThrowError { throw BookingError.fetchFailed }
        return mockBookings.filter { $0.studentId == studentId }
    }

    public func fetchTrainerBookings(trainerId: String) async throws -> [Booking] {
        if shouldThrowError { throw BookingError.fetchFailed }
        return mockBookings.filter { $0.trainerId == trainerId }
    }

    public func updateBookingStatus(bookingId: String, status: BookingStatus) async throws {
        if shouldThrowError { throw BookingError.updateFailed }

        guard let index = mockBookings.firstIndex(where: { $0.id == bookingId }) else {
            throw BookingError.notFound
        }

        let old = mockBookings[index]
        mockBookings[index] = Booking(
            id: old.id,
            studentId: old.studentId,
            trainerId: old.trainerId,
            date: old.date,
            durationInMinutes: old.durationInMinutes,
            status: status,
            notes: old.notes,
            createdAt: old.createdAt
        )
    }
}
#endif
