//
//  BookingsView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Booking Tab
enum BookingTab: String, CaseIterable {
    case upcoming = "Upcoming"
    case past = "Past"

}

// MARK: - Bookings View
public struct BookingsView: View {

    // MARK: - Dependencies
    @Environment(AppEnvironment.self) private var env

    // MARK: - State
    @State private var viewModel: BookingsViewModel?
    @State private var selectedTab: BookingTab = .upcoming
    @State private var bookingToCancel: Booking?
    @State private var isShowingCancellationConfirmation = false
    @State private var isShowingCancellationError = false

    // MARK: - Initialization
    public init() {}

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BookingsFilterPicker(
                    selection: $selectedTab
                )

                content
            }
            .movelyScreen()
            .navigationTitle("My Bookings")
            .task {
                await loadBookings()
            }
            .confirmationDialog(
                "Cancel session?",
                isPresented: $isShowingCancellationConfirmation,
                titleVisibility: .visible
            ) {
                cancellationDialogActions
            } message: {
                cancellationDialogMessage
            }
            .alert(
                "Unable to Cancel",
                isPresented: $isShowingCancellationError
            ) {
                Button("OK", role: .cancel) {
                    viewModel?.clearCancellationError()
                }
            } message: {
                if let message = viewModel?.cancellationErrorMessage {
                    Text(message)
                }
            }
        }
    }

    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        if let viewModel {
            content(for: viewModel)
        } else {
            ProgressView()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
        }
    }

    @ViewBuilder
    private func content(
        for viewModel: BookingsViewModel
    ) -> some View {
        switch viewModel.viewState {
        case .idle, .loading:
            BookingsLoadingView()

        case .loaded(let upcoming, let past):
            loadedContent(
                upcoming: upcoming,
                past: past,
                viewModel: viewModel
            )

        case .failure(let message):
            BookingsErrorView(
                message: message
            ) {
                Task {
                    await viewModel.onRefresh()
                }
            }
        }
    }

    // MARK: - Loaded Content
    @ViewBuilder
    private func loadedContent(
        upcoming: [Booking],
        past: [Booking],
        viewModel: BookingsViewModel
    ) -> some View {
        let bookings = selectedTab == .upcoming
        ? upcoming
        : past

        if bookings.isEmpty {
            BookingsEmptyState(
                message: emptyStateMessage
            )
        } else {
            bookingsList(
                bookings: bookings,
                viewModel: viewModel
            )
        }
    }

    // MARK: - Bookings List
    private func bookingsList(
        bookings: [Booking],
        viewModel: BookingsViewModel
    ) -> some View {
        ScrollView {
            LazyVStack(spacing: .movely.medium) {
                ForEach(bookings) { booking in
                    BookingCard(
                        booking: booking,
                        isCancelling:
                            viewModel.cancellingBookingId == booking.id,
                        onCancel: canCancel(booking) ? {
                            requestCancellation(
                                for: booking
                            )
                        } : nil
                    )
                }
            }
            .padding(
                .horizontal,
                .movely.screenPaddingHorizontal
            )
            .padding(
                .vertical,
                .movely.medium
            )
        }
        .refreshable {
            await viewModel.onRefresh()
        }
    }

    // MARK: - Cancellation Dialog
    @ViewBuilder
    private var cancellationDialogActions: some View {
        Button(
            "Cancel Session",
            role: .destructive
        ) {
            confirmCancellation()
        }

        Button(
            "Keep Session",
            role: .cancel
        ) {
            bookingToCancel = nil
        }
    }

    @ViewBuilder
    private var cancellationDialogMessage: some View {
        if let booking = bookingToCancel {
            Text(
                """
                Cancel your session scheduled for \
                \(formattedDate(for: booking))?
                """
            )
        }
    }

    // MARK: - Cancellation
    private func requestCancellation(
        for booking: Booking
    ) {
        bookingToCancel = booking
        isShowingCancellationConfirmation = true
    }

    private func confirmCancellation() {
        guard
            let booking = bookingToCancel,
            let viewModel
        else {
            return
        }

        isShowingCancellationConfirmation = false

        Task {
            await viewModel.cancelBooking(booking)

            bookingToCancel = nil

            if viewModel.cancellationErrorMessage != nil {
                isShowingCancellationError = true
            }
        }
    }

    private func canCancel(
        _ booking: Booking
    ) -> Bool {
        guard selectedTab == .upcoming else {
            return false
        }

        guard booking.date > Date() else {
            return false
        }

        switch booking.status {
        case .pending, .confirmed:
            return true

        case .completed, .cancelled:
            return false
        }
    }

    // MARK: - Setup
    private func loadBookings() async {
        if let viewModel {
            await viewModel.onRefresh()
            return
        }

        guard let studentId = env.currentUser?.id else {
            return
        }

        let model = BookingsViewModel(
            studentId: studentId,
            fetchBookingsUseCase:
                env.fetchStudentBookingsUseCase,
            cancelBookingUseCase:
                env.cancelBookingUseCase
        )

        viewModel = model

        await model.onAppear()
    }

    // MARK: - Helpers
    private var emptyStateMessage: String {
        switch selectedTab {
        case .upcoming:
            return """
            You don't have any upcoming sessions scheduled.
            """

        case .past:
            return """
            You haven't completed any sessions yet.
            """
        }
    }

    private func formattedDate(
        for booking: Booking
    ) -> String {
        booking.date.formatted(
            .dateTime
                .weekday(.wide)
                .day()
                .month(.wide)
                .hour()
                .minute()
        )
    }

}

// MARK: - Preview
#if DEBUG

#Preview("Bookings - Loaded") {
    BookingsView()
        .environment(
            AppEnvironment.mock(
                isAuthenticated: true
            )
        )
}

#Preview("Bookings - Dark") {
    BookingsView()
        .environment(
            AppEnvironment.mock(
                isAuthenticated: true
            )
        )
        .preferredColorScheme(.dark)
}

#endif
