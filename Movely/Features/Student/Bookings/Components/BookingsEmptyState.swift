//
//  BookingsEmptyState.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/09/26.
//

import SwiftUI

// MARK: - Bookings Empty State
struct BookingsEmptyState: View {

    // MARK: - Properties
    let message: String

    // MARK: - Body
    var body: some View {
        VStack(spacing: .movely.medium) {
            icon
            title
            description
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Icon
    private var icon: some View {
        Image(
            systemName: "calendar.badge.exclamationmark"
        )
        .font(
            .system(size: 64)
        )
        .foregroundStyle(
            .movelyPrimary.opacity(0.5)
        )
    }

    // MARK: - Title
    private var title: some View {
        Text("No bookings found")
            .font(.movely.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.movelyTextPrimary)
    }

    // MARK: - Description
    private var description: some View {
        Text(message)
            .font(.movely.subheadline)
            .foregroundStyle(.movelyTextSecondary)
            .multilineTextAlignment(.center)
            .padding(
                .horizontal,
                .movely.large
            )
    }

}

// MARK: - Preview
#if DEBUG

#Preview("Upcoming Empty State") {
    BookingsEmptyState(
        message: "You don't have any upcoming sessions scheduled."
    )
    .movelyScreen()
}

#Preview("Past Empty State") {
    BookingsEmptyState(
        message: "You haven't completed any sessions yet."
    )
    .movelyScreen()
}

#Preview("Dark") {
    BookingsEmptyState(
        message: "You don't have any upcoming sessions scheduled."
    )
    .movelyScreen()
    .preferredColorScheme(.dark)
}

#endif
