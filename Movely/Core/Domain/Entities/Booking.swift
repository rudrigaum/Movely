//
//  Booking.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/06/26.
//

import Foundation

// MARK: - Booking Status
public enum BookingStatus: String, Codable, Equatable, CaseIterable {
    case pending
    case confirmed
    case completed
    case cancelled
}

// MARK: - Booking Entity
public struct Booking: Identifiable, Codable, Equatable {
    public let id: String
    public let studentId: String
    public let trainerId: String
    public let date: Date
    public let durationInMinutes: Int
    public let status: BookingStatus
    public let notes: String?
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        studentId: String,
        trainerId: String,
        date: Date,
        durationInMinutes: Int = 60,
        status: BookingStatus = .pending,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.studentId = studentId
        self.trainerId = trainerId
        self.date = date
        self.durationInMinutes = durationInMinutes
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
    }
}

// MARK: - Mock
#if DEBUG
public extension Booking {
    static var mock: Booking {
        Booking(
            id: "booking_mock_123",
            studentId: "student_123",
            trainerId: "trainer_456",
            date: Date().addingTimeInterval(86400 * 2),
            durationInMinutes: 60,
            status: .confirmed,
            notes: "Focus on mobility and core strength.",
            createdAt: Date()
        )
    }
}
#endif
