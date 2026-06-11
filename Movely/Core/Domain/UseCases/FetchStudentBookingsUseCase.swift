//
//  FetchStudentBookingsUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 10/06/26.
//

import Foundation

// MARK: - Protocol
public protocol FetchStudentBookingsUseCaseProtocol {
    func execute(studentId: String) async throws -> [Booking]
}

// MARK: - Implementation
public struct FetchStudentBookingsUseCase: FetchStudentBookingsUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: BookingRepositoryProtocol

    // MARK: - Initialization
    public init(repository: BookingRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution
    public func execute(studentId: String) async throws -> [Booking] {
        return try await repository.fetchStudentBookings(studentId: studentId)
    }
}
