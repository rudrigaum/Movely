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
    public private(set) var cancellingBookingId: String?
    public private(set) var cancellationErrorMessage: String?

    // MARK: - Dependencies
    private let studentId: String
    private let fetchBookingsUseCase: FetchStudentBookingsUseCaseProtocol
    private let cancelBookingUseCase: CancelBookingUseCaseProtocol

    // MARK: - Initialization
    public init(
        studentId: String,
        fetchBookingsUseCase: FetchStudentBookingsUseCaseProtocol,
        cancelBookingUseCase: CancelBookingUseCaseProtocol
    ) {
        self.studentId = studentId
        self.fetchBookingsUseCase = fetchBookingsUseCase
        self.cancelBookingUseCase = cancelBookingUseCase
    }

    // MARK: - Actions
    public func onAppear() async {
        if case .loaded = viewState { return }

        await fetchBookings(showLoading: true)
    }

    public func onRefresh() async {
        await fetchBookings(showLoading: false)
    }

    public func cancelBooking(_ booking: Booking) async {
        guard cancellingBookingId == nil else { return }

        cancellingBookingId = booking.id
        cancellationErrorMessage = nil

        defer {
            cancellingBookingId = nil
        }

        do {
            try await cancelBookingUseCase.execute(
                bookingId: booking.id
            )

            removeBookingFromUpcoming(
                bookingId: booking.id
            )

            await reloadAfterCancellation()
        } catch {
            cancellationErrorMessage =
                "Failed to cancel this booking. Please try again."
        }
    }

    public func clearCancellationError() {
        cancellationErrorMessage = nil
    }

    // MARK: - Private Methods
    private func fetchBookings(showLoading: Bool) async {
        if showLoading {
            viewState = .loading
        }

        do {
            viewState = try await makeLoadedState()
        } catch {
            viewState = .failure(
                "Failed to load your bookings. Please try again."
            )
        }
    }

    private func reloadAfterCancellation() async {
        do {
            viewState = try await makeLoadedState()
        } catch {
            cancellationErrorMessage =
                "Your booking was cancelled, but we couldn't refresh the list. Pull to refresh and try again."
        }
    }

    private func makeLoadedState() async throws -> ViewState {
        let allBookings = try await fetchBookingsUseCase.execute(
            studentId: studentId
        )

        let now = Date()

        let upcoming = allBookings
            .filter {
                $0.date >= now &&
                $0.status != .cancelled
            }
            .sorted {
                $0.date < $1.date
            }

        let past = allBookings
            .filter {
                $0.date < now ||
                $0.status == .cancelled
            }
            .sorted {
                $0.date > $1.date
            }

        return .loaded(
            upcoming: upcoming,
            past: past
        )
    }

    private func removeBookingFromUpcoming(
        bookingId: String
    ) {
        guard case let .loaded(upcoming, past) = viewState else {
            return
        }

        let updatedUpcoming = upcoming.filter {
            $0.id != bookingId
        }

        viewState = .loaded(
            upcoming: updatedUpcoming,
            past: past
        )
    }
}
