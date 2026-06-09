//
//  BookingDTO.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/06/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Booking DTO
public struct BookingDTO: Codable {
    @DocumentID public var id: String?
    public let studentId: String
    public let trainerId: String
    public let date: Date
    public let durationInMinutes: Int
    public let status: String
    public let notes: String?
    public let createdAt: Date

    // MARK: - Initializer
    public init(
        id: String? = nil,
        studentId: String,
        trainerId: String,
        date: Date,
        durationInMinutes: Int,
        status: String,
        notes: String?,
        createdAt: Date
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

// MARK: - Mappers
public extension BookingDTO {

    func toDomain() -> Booking? {
        guard let id = id, let bookingStatus = BookingStatus(rawValue: status) else {
            return nil
        }

        return Booking(
            id: id,
            studentId: studentId,
            trainerId: trainerId,
            date: date,
            durationInMinutes: durationInMinutes,
            status: bookingStatus,
            notes: notes,
            createdAt: createdAt
        )
    }

    static func fromDomain(_ booking: Booking) -> BookingDTO {
        return BookingDTO(
            id: booking.id,
            studentId: booking.studentId,
            trainerId: booking.trainerId,
            date: booking.date,
            durationInMinutes: booking.durationInMinutes,
            status: booking.status.rawValue,
            notes: booking.notes,
            createdAt: booking.createdAt
        )
    }
}
