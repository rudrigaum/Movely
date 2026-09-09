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
