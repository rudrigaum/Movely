//
//  TrainerCard.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 16/03/26.
//

import Foundation
import SwiftUI

// MARK: - Trainer Card
/// Reusable card component for displaying trainer info.
/// Used in HomeView (grid) and SearchView (list).
public struct TrainerCard: View {

    // MARK: - Properties
    let trainer: Trainer
    let onTap: () -> Void

    // MARK: - Init
    public init(trainer: Trainer, onTap: @escaping () -> Void) {
        self.trainer = trainer
        self.onTap = onTap
    }

    // MARK: - Body
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: .movely.tiny) {
                avatarSection
                infoSection
                ratingRow
                priceRow
            }
            .padding(.movely.small)
            .background(.movelyBackgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: .movely.radiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: .movely.radiusLarge)
                    .strokeBorder(.movelyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(MovelyPressButtonStyle())
    }

    // MARK: - Avatar Section
    private var avatarSection: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let avatarURL = trainer.avatarURL, !avatarURL.isEmpty {
                    AsyncImage(url: URL(string: avatarURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        avatarPlaceholder
                    }
                } else {
                    avatarPlaceholder
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: .movely.radiusMedium))

            if !trainer.isAvailable {
                unavailableBadge
            }

            if trainer.isFeatured {
                featuredBadge
            }
        }
    }

    // MARK: - Avatar Placeholder
    private var avatarPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [.movelyPrimary.opacity(0.15), .movelyPrimary.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(trainer.name.prefix(1))
                .font(.movely.title1)
                .fontWeight(.bold)
                .foregroundStyle(.movelyPrimary)
        }
    }

    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(trainer.name)
                .font(.movely.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextPrimary)
                .lineLimit(1)

            if let distance = trainer.location.distanceText {
                Label(distance, systemImage: "location.fill")
                    .font(.movely.caption1)
                    .foregroundStyle(.movelyTextSecondary)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Rating Row
    private var ratingRow: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundStyle(.movelyWarning)
            Text(String(format: "%.1f", trainer.rating))
                .font(.movely.caption1)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextPrimary)
            Text("(\(trainer.reviewCount))")
                .font(.movely.caption1)
                .foregroundStyle(.movelyTextSecondary)
        }
    }

    // MARK: - Price Row
    private var priceRow: some View {
        HStack(spacing: 2) {
            Text("R$ \(Int(trainer.hourlyRate))")
                .font(.movely.price)
                .foregroundStyle(.movelyPrimary)
            Text("/hr")
                .font(.movely.caption1)
                .foregroundStyle(.movelyTextSecondary)
        }
    }

    // MARK: - Unavailable Badge
    private var unavailableBadge: some View {
        Text("Unavailable")
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.movelyTextSecondary)
            .clipShape(Capsule())
            .padding(6)
    }

    // MARK: - Featured Badge
    private var featuredBadge: some View {
        Group {
            if trainer.isAvailable {
                Text("⭐ Featured")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.movelyPrimary)
                    .clipShape(Capsule())
                    .padding(6)
            }
        }
    }
}

// MARK: - Press Style
private struct MovelyPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Trainer Card - Available") {
    HStack {
        TrainerCard(trainer: Trainer.mockList[0]) {}
        TrainerCard(trainer: Trainer.mockList[1]) {}
    }
    .padding()
    .background(.movelyBackground)
}

#Preview("Trainer Card - Unavailable") {
    HStack {
        TrainerCard(trainer: Trainer.mockList[2]) {}
        TrainerCard(trainer: Trainer.mockList[3]) {}
    }
    .padding()
    .background(.movelyBackground)
}

#Preview("Trainer Card - Dark") {
    HStack {
        TrainerCard(trainer: Trainer.mockList[0]) {}
        TrainerCard(trainer: Trainer.mockList[1]) {}
    }
    .padding()
    .background(.movelyBackground)
    .preferredColorScheme(.dark)
}
