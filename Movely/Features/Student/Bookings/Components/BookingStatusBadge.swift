//
//  BookingStatusBadge.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/09/26.
//

import Foundation
import SwiftUI

// MARK: - Booking Status Badge
struct BookingStatusBadge: View {

    // MARK: - Properties
    let status: BookingStatus

    // MARK: - Body
    var body: some View {
        Text(title)
            .font(
                .system(
                    size: 11,
                    weight: .bold
                )
            )
            .padding(
                .horizontal,
                .movely.tiny
            )
            .padding(
                .vertical,
                .movely.micro
            )
            .background(
                badgeColor.opacity(0.15)
            )
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    // MARK: - Title
    private var title: String {
        status.rawValue.capitalized
    }

    // MARK: - Color
    private var badgeColor: Color {
        switch status {
        case .pending:
            return .movelyWarning

        case .confirmed:
            return .movelyPrimary

        case .completed:
            return .green

        case .cancelled:
            return .movelyError
        }
    }

}

// MARK: - Preview

#if DEBUG

#Preview("Pending") {
    BookingStatusBadge(
        status: .pending
    )
    .padding()
}

#Preview("Confirmed") {
    BookingStatusBadge(
        status: .confirmed
    )
    .padding()
}

#Preview("Completed") {
    BookingStatusBadge(
        status: .completed
    )
    .padding()
}

#Preview("Cancelled") {
    BookingStatusBadge(
        status: .cancelled
    )
    .padding()
}

#Preview("Dark") {
    BookingStatusBadge(
        status: .confirmed
    )
    .padding()
    .preferredColorScheme(.dark)
}

#endif
