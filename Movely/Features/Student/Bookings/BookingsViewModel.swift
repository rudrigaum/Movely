//
//  BookingsViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 10/06/26.
//

import Foundation
import SwiftUI

// MARK: - View Model
@Observable
@MainActor
public final class BookingsViewModel {

    // MARK: - View State
    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded(upcoming: [Booking], past: [Booking])
        case failure(String)
    }

    // MARK: - Properties
    public private(set) var viewState: ViewState = .idle

    // MARK: - Dependencies
    private let studentId: String
    private let fetchBookingsUseCase: FetchStudentBookingsUseCaseProtocol

    // MARK: - Initialization
    public init(
        studentId: String,
        fetchBookingsUseCase: FetchStudentBookingsUseCaseProtocol
    ) {
        self.studentId = studentId
        self.fetchBookingsUseCase = fetchBookingsUseCase
    }

    // MARK: - Actions
    public func onAppear() async {
        if case .loaded = viewState { return }
        await fetchBookings()
    }

    public func onRefresh() async {
        await fetchBookings()
    }

    // MARK: - Private Methods
    private func fetchBookings() async {
        viewState = .loading

        do {
            let allBookings = try await fetchBookingsUseCase.execute(studentId: studentId)

            let now = Date()
            let upcoming = allBookings.filter { $0.date >= now && $0.status != .cancelled }
            let past = allBookings.filter { $0.date < now || $0.status == .cancelled }
            let sortedPast = past.sorted { $0.date > $1.date }

            viewState = .loaded(upcoming: upcoming, past: sortedPast)

        } catch {
            viewState = .failure("Failed to load your bookings. Please try again.")
        }
    }
}
