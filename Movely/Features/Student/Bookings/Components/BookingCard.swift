//
//  BookingCard.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/09/26.
//

import Foundation
import SwiftUI

// MARK: - Booking Card
struct BookingCard: View {

    // MARK: - Properties
    let booking: Booking
    let isCancelling: Bool
    let onCancel: (() -> Void)?

    // MARK: - Body
    var body: some View {
        MovelyCard {
            VStack(
                alignment: .leading,
                spacing: .movely.small
            ) {
                header

                Divider()

                details

                if let notes = booking.notes {
                    notesSection(notes)
                }

                if let onCancel {
                    cancellationSection(
                        action: onCancel
                    )
                }
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .top) {
            dateSection

            Spacer()

            BookingStatusBadge(
                status: booking.status
            )
        }
    }

    private var dateSection: some View {
        VStack(
            alignment: .leading,
            spacing: 2
        ) {
            Text(formattedDate)
                .font(.movely.headline)
                .foregroundStyle(.movelyTextPrimary)

            Text(formattedTime)
                .font(.movely.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyPrimary)
        }
    }

    // MARK: - Details
    private var details: some View {
        HStack(spacing: .movely.medium) {
            Label(
                "\(booking.durationInMinutes) min",
                systemImage: "clock.fill"
            )

            Label(
                "Session",
                systemImage: "figure.run"
            )
        }
        .font(.movely.caption1)
        .foregroundStyle(.movelyTextSecondary)
    }

    // MARK: - Notes
    private func notesSection(
        _ notes: String
    ) -> some View {
        Text("Note: \(notes)")
            .font(.movely.caption2)
            .foregroundStyle(.movelyTextSecondary)
            .padding(
                .top,
                .movely.micro
            )
            .lineLimit(2)
    }

    // MARK: - Cancellation
    private func cancellationSection(
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: .movely.tiny) {
            Divider()
                .padding(
                    .top,
                    .movely.micro
                )

            Button(action: action) {
                cancellationButtonContent
            }
            .buttonStyle(.plain)
            .disabled(isCancelling)
        }
    }

    private var cancellationButtonContent: some View {
        HStack(spacing: .movely.tiny) {
            if isCancelling {
                ProgressView()
                    .controlSize(.small)
                    .tint(.movelyError)
            }

            Text(
                isCancelling
                    ? "Cancelling..."
                    : "Cancel Session"
            )
            .font(.movely.subheadline)
            .fontWeight(.semibold)
        }
        .foregroundStyle(.movelyError)
        .frame(maxWidth: .infinity)
        .padding(
            .vertical,
            .movely.tiny
        )
        .contentShape(Rectangle())
    }

    // MARK: - Formatting
    private var formattedDate: String {
        booking.date.formatted(
            .dateTime
                .weekday(.wide)
                .day()
                .month(.wide)
        )
    }

    private var formattedTime: String {
        booking.date.formatted(
            .dateTime
                .hour()
                .minute()
        )
    }

}

// MARK: - Preview
#if DEBUG

private extension Booking {

    static let previewConfirmed = Booking(
        id: "preview-confirmed",
        studentId: "student-preview",
        trainerId: "trainer-preview",
        date: Date(
            timeIntervalSince1970: 1_810_000_000
        ),
        durationInMinutes: 60,
        status: .confirmed,
        notes: "Focus on strength and mobility.",
        createdAt: Date(
            timeIntervalSince1970: 1_809_000_000
        )
    )

    static let previewPending = Booking(
        id: "preview-pending",
        studentId: "student-preview",
        trainerId: "trainer-preview",
        date: Date(
            timeIntervalSince1970: 1_810_086_400
        ),
        durationInMinutes: 45,
        status: .pending,
        notes: nil,
        createdAt: Date(
            timeIntervalSince1970: 1_809_000_000
        )
    )

    static let previewCancelled = Booking(
        id: "preview-cancelled",
        studentId: "student-preview",
        trainerId: "trainer-preview",
        date: Date(
            timeIntervalSince1970: 1_809_900_000
        ),
        durationInMinutes: 60,
        status: .cancelled,
        notes: "Lower body session.",
        createdAt: Date(
            timeIntervalSince1970: 1_809_000_000
        )
    )

}

#Preview("Confirmed") {
    BookingCard(
        booking: .previewConfirmed,
        isCancelling: false,
        onCancel: {}
    )
    .padding()
    .movelyScreen()
}

#Preview("Pending") {
    BookingCard(
        booking: .previewPending,
        isCancelling: false,
        onCancel: {}
    )
    .padding()
    .movelyScreen()
}

#Preview("Cancelling") {
    BookingCard(
        booking: .previewConfirmed,
        isCancelling: true,
        onCancel: {}
    )
    .padding()
    .movelyScreen()
}

#Preview("Cancelled") {
    BookingCard(
        booking: .previewCancelled,
        isCancelling: false,
        onCancel: nil
    )
    .padding()
    .movelyScreen()
}

#Preview("Dark") {
    BookingCard(
        booking: .previewConfirmed,
        isCancelling: false,
        onCancel: {}
    )
    .padding()
    .movelyScreen()
    .preferredColorScheme(.dark)
}

#endif
