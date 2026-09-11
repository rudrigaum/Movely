//
//  BookingsErrorView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/09/26.
//

import SwiftUI

// MARK: - Bookings Error View
struct BookingsErrorView: View {

    // MARK: - Properties
    let message: String
    let onRetry: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: .movely.large) {
            icon
            errorMessage
            retryButton
        }
        .padding(
            .movely.screenPaddingHorizontal
        )
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Icon
    private var icon: some View {
        Image(
            systemName: "exclamationmark.triangle.fill"
        )
        .font(
            .system(size: 48)
        )
        .foregroundStyle(
            .movelyError
        )
    }

    // MARK: - Message
    private var errorMessage: some View {
        Text(message)
            .font(.movely.subheadline)
            .foregroundStyle(.movelyTextSecondary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Retry Button
    private var retryButton: some View {
        MovelyButton("Try Again") {
            onRetry()
        }
    }

}

// MARK: - Preview
#if DEBUG

#Preview("Fetch Error") {
    BookingsErrorView(
        message: "Failed to load your bookings. Please try again.",
        onRetry: {}
    )
    .movelyScreen()
}

#Preview("Long Error Message") {
    BookingsErrorView(
        message: """
        We couldn't load your bookings right now. \
        Check your connection and try again.
        """,
        onRetry: {}
    )
    .movelyScreen()
}

#Preview("Dark") {
    BookingsErrorView(
        message: "Failed to load your bookings. Please try again.",
        onRetry: {}
    )
    .movelyScreen()
    .preferredColorScheme(.dark)
}

#endif
