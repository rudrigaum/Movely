//
//  BookingRepository.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/06/26.
//

import Foundation
import FirebaseFirestore

public final class BookingRepository: BookingRepositoryProtocol {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private let collectionName = "bookings"

    // MARK: - Initialization
    public init() {}

    // MARK: - Create
    public func createBooking(_ booking: Booking) async throws {
        let dto = BookingDTO.fromDomain(booking)
        let documentRef = db.collection(collectionName).document(booking.id)

        do {
            try documentRef.setData(from: dto)
        } catch {
            throw BookingError.createFailed
        }
    }

    // MARK: - Fetch (Student)
    public func fetchStudentBookings(studentId: String) async throws -> [Booking] {
        do {
            let snapshot = try await db.collection(collectionName)
                .whereField("studentId", isEqualTo: studentId)
                .order(by: "date", descending: false) AppEnvironment
                .getDocuments()

            return snapshot.documents.compactMap { document in
                try? document.data(as: BookingDTO.self).toDomain()
            }
        } catch {
            throw BookingError.fetchFailed
        }
    }

    // MARK: - Fetch (Trainer)
    public func fetchTrainerBookings(trainerId: String) async throws -> [Booking] {
        do {
            let snapshot = try await db.collection(collectionName)
                .whereField("trainerId", isEqualTo: trainerId)
                .order(by: "date", descending: false)
                .getDocuments()

            return snapshot.documents.compactMap { document in
                try? document.data(as: BookingDTO.self).toDomain()
            }
        } catch {
            throw BookingError.fetchFailed
        }
    }

    // MARK: - Update
    public func updateBookingStatus(bookingId: String, status: BookingStatus) async throws {
        let documentRef = db.collection(collectionName).document(bookingId)

        do {
            try await documentRef.updateData([
                "status": status.rawValue
            ])
        } catch {
            throw BookingError.updateFailed
        }
    }
}
