//
//  TrainerProfileHeaderView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/10/26.
//

import Foundation
import SwiftUI

// MARK: - Trainer Profile Header

struct TrainerProfileHeaderView: View {

    // MARK: - Properties

    let trainer: Trainer

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    .movelyPrimary.opacity(0.8),
                    .movelyPrimary.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)

            VStack(
                alignment: .leading,
                spacing: .movely.small
            ) {
                avatarSection
                trainerInformation
            }
            .padding(
                .horizontal,
                .movely.screenPaddingHorizontal
            )
            .padding(.bottom, .movely.large)
        }
    }

    // MARK: - Avatar

    private var avatarSection: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(
                        width: .movely.avatarXLarge,
                        height: .movely.avatarXLarge
                    )

                Text(trainer.name.prefix(1))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding(.top, 60)
    }

    // MARK: - Trainer Information

    private var trainerInformation: some View {
        VStack(
            alignment: .leading,
            spacing: .movely.micro
        ) {
            Text(trainer.name)
                .font(.movely.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Label(
                trainer.location.displayName,
                systemImage: "location.fill"
            )
            .font(.movely.subheadline)
            .foregroundStyle(.white.opacity(0.85))

            ratingSection
        }
    }

    // MARK: - Rating

    private var ratingSection: some View {
        HStack(spacing: .movely.tiny) {
            ratingStars

            Text(
                String(format: "%.1f", trainer.rating)
            )
            .font(.movely.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)

            Text("(\(trainer.reviewCount) reviews)")
                .font(.movely.caption1)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var ratingStars: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(
                    systemName: star <= Int(trainer.rating.rounded())
                        ? "star.fill"
                        : "star"
                )
                .font(.system(size: 12))
                .foregroundStyle(.movelyWarning)
            }
        }
    }

}

// MARK: - Preview

#if DEBUG

#Preview("Trainer Header - Light") {
    TrainerProfileHeaderView(
        trainer: Trainer.mockList[0]
    )
    .movelyScreen()
    .preferredColorScheme(.light)
}

#Preview("Trainer Header - Dark") {
    TrainerProfileHeaderView(
        trainer: Trainer.mockList[0]
    )
    .movelyScreen()
    .preferredColorScheme(.dark)
}

#endif
