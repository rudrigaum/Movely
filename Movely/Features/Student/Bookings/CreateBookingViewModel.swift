//
//  CreateBookingViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/06/26.
//

import Foundation
import SwiftUI

// MARK: - View Model
@Observable
@MainActor
public final class CreateBookingViewModel {

    // MARK: - View State
    public enum ViewState: Equatable {
        case idle
        case loading
        case success
        case failure(String)
    }

    // MARK: - Properties
    public var state: ViewState = .idle
    public var selectedDate: Date = Date().addingTimeInterval(86400)
    public var notes: String = ""

    // MARK: - Dependencies
    private let trainerId: String
    private let studentId: String
    private let createBookingUseCase: CreateBookingUseCase

    // MARK: - Initialization
    public init(
        trainerId: String,
        studentId: String,
        createBookingUseCase: CreateBookingUseCase
    ) {
        self.trainerId = trainerId
        self.studentId = studentId
        self.createBookingUseCase = createBookingUseCase
    }

    // MARK: - Actions
    public func createBooking() async {
        state = .loading

        do {
            try await createBookingUseCase.execute(
                studentId: studentId,
                trainerId: trainerId,
                date: selectedDate,
                durationInMinutes: 60,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
            )
            state = .success
        } catch let error as LocalizedError {
            state = .failure(error.errorDescription ?? "Failed to book session. Please try again.")
        } catch {
            state = .failure("An unexpected error occurred.")
        }
    }
}
