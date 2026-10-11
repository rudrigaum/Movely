//
//  TrainerProfileDetailsView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/10/26.
//

import Foundation
import SwiftUI

// MARK: - Trainer Profile Details

struct TrainerProfileDetailsView: View {

    // MARK: - Properties

    let trainer: Trainer

    // MARK: - Body

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: .movely.small
        ) {
            Text("Details")
                .font(.movely.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextPrimary)

            MovelyCard {
                VStack(spacing: 0) {
                    hourlyRateRow

                    Divider()
                        .padding(.leading, 44)

                    distanceRow

                    Divider()
                        .padding(.leading, 44)

                    availabilityRow
                }
            }
        }
    }

    // MARK: - Hourly Rate

    private var hourlyRateRow: some View {
        TrainerDetailRow(
            icon: "clock.fill",
            title: "Hourly Rate",
            value: "R$ \(Int(trainer.hourlyRate))/hr"
        )
    }

    // MARK: - Distance

    private var distanceRow: some View {
        TrainerDetailRow(
            icon: "location.fill",
            title: "Distance",
            value: trainer.location.distanceText ?? "N/A"
        )
    }

    // MARK: - Availability

    private var availabilityRow: some View {
        TrainerDetailRow(
            icon: "checkmark.seal.fill",
            title: "Availability",
            value: trainer.isAvailable
                ? "Available now"
                : "Unavailable"
        )
    }

}

// MARK: - Trainer Detail Row

private struct TrainerDetailRow: View {

    // MARK: - Properties

    let icon: String
    let title: String
    let value: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: .movely.small) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.movelyPrimary)
                .frame(width: 28)

            Text(title)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)

            Spacer()

            Text(value)
                .font(.movely.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.movelyTextPrimary)
        }
        .padding(.movely.medium)
    }

}

// MARK: - Preview

#if DEBUG

#Preview("Trainer Details - Available") {
    TrainerProfileDetailsView(
        trainer: Trainer.mockList[0]
    )
    .padding()
    .movelyScreen()
}

#Preview("Trainer Details - Unavailable") {
    TrainerProfileDetailsView(
        trainer: Trainer.mockList[2]
    )
    .padding()
    .movelyScreen()
}

#Preview("Trainer Details - Dark") {
    TrainerProfileDetailsView(
        trainer: Trainer.mockList[0]
    )
    .padding()
    .movelyScreen()
    .preferredColorScheme(.dark)
}

#endif
