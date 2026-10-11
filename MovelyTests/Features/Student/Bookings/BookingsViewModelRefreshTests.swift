//
//  BookingsViewModelRefreshTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 10/10/26.
//

import Foundation
import Testing

@testable import Movely

// MARK: - Bookings View Model Refresh Tests

@Suite("BookingsViewModel Refresh Tests")
@MainActor
struct BookingsViewModelRefreshTests {

    // MARK: - Refresh Failure

    @Test("Refresh failure preserves previously loaded bookings")
    func refreshFailurePreservesLoadedBookings() async {
        let booking = makeBooking(id: "original-booking")
        let context = makeSUT(results: [[booking]])

        await context.sut.onAppear()

        let originalState = context.sut.viewState

        context.fetchUseCase.errorToThrow = BookingError.fetchFailed

        await context.sut.onRefresh()

        #expect(context.sut.viewState == originalState)
        #expect(context.fetchUseCase.executeCallCount == 2)
        #expect(
            context.sut.refreshErrorMessage ==
                "Failed to refresh your bookings. Please try again."
        )
    }

    // MARK: - Error Dismissal

    @Test("Clearing refresh error preserves loaded bookings")
    func clearRefreshErrorPreservesLoadedBookings() async {
        let booking = makeBooking(id: "original-booking")
        let context = makeSUT(results: [[booking]])

        await context.sut.onAppear()

        let originalState = context.sut.viewState

        context.fetchUseCase.errorToThrow = BookingError.fetchFailed

        await context.sut.onRefresh()

        #expect(context.sut.refreshErrorMessage != nil)

        context.sut.clearRefreshError()

        #expect(context.sut.refreshErrorMessage == nil)
        #expect(context.sut.viewState == originalState)
    }

    // MARK: - Refresh Recovery

    @Test("Successful refresh updates bookings and clears previous error")
    func successfulRefreshClearsError() async {
        let originalBooking = makeBooking(id: "original-booking")
        let updatedBooking = makeBooking(id: "updated-booking")

        let context = makeSUT(
            results: [
                [originalBooking],
                [originalBooking],
                [updatedBooking]
            ]
        )

        await context.sut.onAppear()

        context.fetchUseCase.errorToThrow = BookingError.fetchFailed

        await context.sut.onRefresh()

        #expect(context.sut.refreshErrorMessage != nil)

        context.fetchUseCase.errorToThrow = nil

        await context.sut.onRefresh()

        guard case let .loaded(
            upcoming,
            past
        ) = context.sut.viewState else {
            Issue.record("Expected loaded view state after refresh")
            return
        }

        #expect(upcoming.map(\.id) == ["updated-booking"])
        #expect(past.isEmpty)
        #expect(context.sut.refreshErrorMessage == nil)
        #expect(context.fetchUseCase.executeCallCount == 3)
    }

    // MARK: - Test Context

    private struct TestContext {
        let sut: BookingsViewModel
        let fetchUseCase: FetchStudentBookingsUseCaseStub
    }

    // MARK: - Factory

    private func makeSUT(
        results: [[Booking]]
    ) -> TestContext {
        let fetchUseCase = FetchStudentBookingsUseCaseStub(
            results: results
        )

        let sut = BookingsViewModel(
            studentId: "student-123",
            fetchBookingsUseCase: fetchUseCase,
            cancelBookingUseCase: CancelBookingUseCaseSpy()
        )

        return TestContext(
            sut: sut,
            fetchUseCase: fetchUseCase
        )
    }

    // MARK: - Helpers

    private func makeBooking(
        id: String
    ) -> Booking {
        Booking(
            id: id,
            studentId: "student-123",
            trainerId: "trainer-123",
            date: Date().addingTimeInterval(86_400),
            status: .confirmed
        )
    }
}
