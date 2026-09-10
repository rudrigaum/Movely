//
//  BookingsViewModelTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 09/09/26.
//

import Foundation
import Testing

@testable import Movely

// MARK: - Bookings View Model Tests
@Suite("BookingsViewModel Tests")
@MainActor
struct BookingsViewModelTests {

    // MARK: - Loading
    @Test("On appear loads and separates upcoming and past bookings")
    func onAppearLoadsAndSeparatesBookings() async {
        let upcomingBooking = makeBooking(
            id: "upcoming",
            date: Date().addingTimeInterval(3_600),
            status: .confirmed
        )

        let pastBooking = makeBooking(
            id: "past",
            date: Date().addingTimeInterval(-3_600),
            status: .completed
        )

        let cancelledBooking = makeBooking(
            id: "cancelled",
            date: Date().addingTimeInterval(7_200),
            status: .cancelled
        )

        let context = makeSUT(
            bookings: [
                upcomingBooking,
                pastBooking,
                cancelledBooking
            ]
        )

        await context.sut.onAppear()

        #expect(
            context.fetchUseCase.executeCallCount == 1
        )

        #expect(
            context.fetchUseCase.receivedStudentId ==
                "student-123"
        )

        guard case let .loaded(
            upcoming,
            past
        ) = context.sut.viewState else {
            Issue.record(
                "Expected loaded view state"
            )
            return
        }

        #expect(
            upcoming.map(\.id) == ["upcoming"]
        )

        #expect(
            past.map(\.id).contains("past")
        )

        #expect(
            past.map(\.id).contains("cancelled")
        )
    }

    @Test("On appear does not fetch again after data is loaded")
    func onAppearDoesNotFetchAgainWhenAlreadyLoaded() async {
        let booking = makeBooking(
            date: Date().addingTimeInterval(3_600)
        )

        let context = makeSUT(
            bookings: [booking]
        )

        await context.sut.onAppear()
        await context.sut.onAppear()

        #expect(
            context.fetchUseCase.executeCallCount == 1
        )
    }

    @Test("Fetch failure exposes failure view state")
    func fetchFailureExposesFailureState() async {
        let sut = makeSUT(
            fetchError: BookingError.fetchFailed
        ).sut

        await sut.onAppear()

        guard case let .failure(message) = sut.viewState else {
            Issue.record(
                "Expected failure view state"
            )
            return
        }

        #expect(
            message ==
                "Failed to load your bookings. Please try again."
        )
    }

    // MARK: - Cancellation
    @Test("Cancel booking sends correct booking id")
    func cancelBookingSendsCorrectBookingId() async {
        let booking = makeBooking(
            id: "booking-to-cancel",
            date: Date().addingTimeInterval(3_600)
        )

        let cancelledBooking = makeBooking(
            id: booking.id,
            date: booking.date,
            status: .cancelled
        )

        let context = makeSUT(
            fetchResults: [
                [booking],
                [cancelledBooking]
            ]
        )

        await context.sut.onAppear()
        await context.sut.cancelBooking(booking)

        #expect(
            context.cancelUseCase.executeCallCount == 1
        )

        #expect(
            context.cancelUseCase.receivedBookingId ==
                "booking-to-cancel"
        )
    }

    @Test("Successful cancellation moves booking out of upcoming")
    func successfulCancellationUpdatesLoadedState() async {
        let booking = makeBooking(
            id: "booking-to-cancel",
            date: Date().addingTimeInterval(3_600),
            status: .confirmed
        )

        let cancelledBooking = makeBooking(
            id: booking.id,
            date: booking.date,
            status: .cancelled
        )

        let sut = makeSUT(
            fetchResults: [
                [booking],
                [cancelledBooking]
            ]
        ).sut

        await sut.onAppear()
        await sut.cancelBooking(booking)

        guard case let .loaded(
            upcoming,
            past
        ) = sut.viewState else {
            Issue.record(
                "Expected loaded view state"
            )
            return
        }

        #expect(upcoming.isEmpty)

        #expect(
            past.map(\.id) == [
                "booking-to-cancel"
            ]
        )

        #expect(
            sut.cancellingBookingId == nil
        )

        #expect(
            sut.cancellationErrorMessage == nil
        )
    }

    @Test("Cancellation failure keeps list and exposes action error")
    func cancellationFailureExposesError() async {
        let booking = makeBooking(
            id: "booking-to-cancel",
            date: Date().addingTimeInterval(3_600)
        )

        let sut = makeSUT(
            bookings: [booking],
            cancellationError: BookingError.updateFailed
        ).sut

        await sut.onAppear()
        await sut.cancelBooking(booking)

        guard case let .loaded(
            upcoming,
            _
        ) = sut.viewState else {
            Issue.record(
                "Expected loaded view state"
            )
            return
        }

        #expect(
            upcoming.map(\.id) == [
                "booking-to-cancel"
            ]
        )

        #expect(
            sut.cancellingBookingId == nil
        )

        #expect(
            sut.cancellationErrorMessage ==
                "Failed to cancel this booking. Please try again."
        )
    }

    @Test("Clear cancellation error removes action error")
    func clearCancellationErrorRemovesError() async {
        let booking = makeBooking(
            date: Date().addingTimeInterval(3_600)
        )

        let sut = makeSUT(
            bookings: [booking],
            cancellationError: BookingError.updateFailed
        ).sut

        await sut.onAppear()
        await sut.cancelBooking(booking)

        #expect(
            sut.cancellationErrorMessage != nil
        )

        sut.clearCancellationError()

        #expect(
            sut.cancellationErrorMessage == nil
        )
    }

    // MARK: - Test Context
    private struct TestContext {

        let sut: BookingsViewModel
        let fetchUseCase: FetchStudentBookingsUseCaseStub
        let cancelUseCase: CancelBookingUseCaseSpy

    }

    // MARK: - Factory
    private func makeSUT(
        bookings: [Booking] = [],
        fetchResults: [[Booking]]? = nil,
        fetchError: Error? = nil,
        cancellationError: Error? = nil
    ) -> TestContext {
        let fetchUseCase = FetchStudentBookingsUseCaseStub(
            results: fetchResults ?? [bookings],
            errorToThrow: fetchError
        )

        let cancelUseCase = CancelBookingUseCaseSpy(
            errorToThrow: cancellationError
        )

        let sut = BookingsViewModel(
            studentId: "student-123",
            fetchBookingsUseCase: fetchUseCase,
            cancelBookingUseCase: cancelUseCase
        )

        return TestContext(
            sut: sut,
            fetchUseCase: fetchUseCase,
            cancelUseCase: cancelUseCase
        )
    }

    private func makeBooking(
        id: String = "booking-123",
        date: Date,
        status: BookingStatus = .confirmed
    ) -> Booking {
        Booking(
            id: id,
            studentId: "student-123",
            trainerId: "trainer-123",
            date: date,
            durationInMinutes: 60,
            status: status,
            notes: nil,
            createdAt: Date()
        )
    }

}
