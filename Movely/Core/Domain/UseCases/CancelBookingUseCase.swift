//
//  CancelBookingUseCase.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 12/06/26.
//

import Foundation

// MARK: - Protocol
public protocol CancelBookingUseCaseProtocol {
    func execute(bookingId: String) async throws
}

// MARK: - Implementation
public struct CancelBookingUseCase: CancelBookingUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: BookingRepositoryProtocol

    // MARK: - Initialization
    public init(repository: BookingRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execution
    public func execute(bookingId: String) async throws {
        try await repository.updateBookingStatus(bookingId: bookingId, status: .cancelled)
    }
}
