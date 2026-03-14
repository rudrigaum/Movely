//
//  Trainer.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation

// MARK: - Trainer Entity
public struct Trainer: Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let avatarURL: String?
    public let bio: String
    public let specialties: [TrainingCategory]
    public let rating: Double
    public let reviewCount: Int
    public let hourlyRate: Double
    public let location: TrainerLocation
    public let isAvailable: Bool
    public let isFeatured: Bool
}

// MARK: - Training Category
public enum TrainingCategory: String, CaseIterable, Identifiable {
    case strength = "Strength"
    case yoga = "Yoga"
    case functional = "Functional"
    case cardio = "Cardio"
    case pilates = "Pilates"
    case crossfit = "CrossFit"
    case stretching = "Stretching"
    case hiit = "HIIT"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .functional: return "figure.strengthtraining.functional"
        case .cardio: return "figure.run"
        case .pilates: return "figure.pilates"
        case .crossfit: return "figure.highintensity.intervaltraining"
        case .stretching: return "figure.flexibility"
        case .hiit: return "timer"
        }
    }
}

// MARK: - Trainer Location
public struct TrainerLocation: Equatable, Hashable {
    public let city: String
    public let state: String
    public let distanceKm: Double?

    public var displayName: String {
        "\(city), \(state)"
    }

    public var distanceText: String? {
        guard let distance = distanceKm else { return nil }
        return String(format: "%.1f km away", distance)
    }
}

// MARK: - Debug Mocks
#if DEBUG
public extension Trainer {
    static let mockList: [Trainer] = [
        Trainer(
            id: "1",
            name: "Carlos Mendes",
            avatarURL: nil,
            bio: "Certified personal trainer with 8 years of experience in strength and conditioning.",
            specialties: [.strength, .functional],
            rating: 4.9,
            reviewCount: 134,
            hourlyRate: 120.0,
            location: TrainerLocation(city: "São Paulo", state: "SP", distanceKm: 1.2),
            isAvailable: true,
            isFeatured: true
        ),
        Trainer(
            id: "2",
            name: "Ana Paula Lima",
            avatarURL: nil,
            bio: "Yoga and pilates instructor focused on mindfulness and body awareness.",
            specialties: [.yoga, .pilates, .stretching],
            rating: 4.8,
            reviewCount: 89,
            hourlyRate: 100.0,
            location: TrainerLocation(city: "São Paulo", state: "SP", distanceKm: 2.5),
            isAvailable: true,
            isFeatured: true
        ),
        Trainer(
            id: "3",
            name: "Rafael Costa",
            avatarURL: nil,
            bio: "CrossFit and HIIT specialist. Former athlete with competition experience.",
            specialties: [.crossfit, .hiit, .cardio],
            rating: 4.7,
            reviewCount: 201,
            hourlyRate: 150.0,
            location: TrainerLocation(city: "São Paulo", state: "SP", distanceKm: 3.8),
            isAvailable: false,
            isFeatured: true
        ),
        Trainer(
            id: "4",
            name: "Juliana Souza",
            avatarURL: nil,
            bio: "Functional training and cardio coach. Specializes in weight loss programs.",
            specialties: [.functional, .cardio, .hiit],
            rating: 4.6,
            reviewCount: 57,
            hourlyRate: 90.0,
            location: TrainerLocation(city: "São Paulo", state: "SP", distanceKm: 0.8),
            isAvailable: true,
            isFeatured: false
        ),
        Trainer(
            id: "5",
            name: "Bruno Ferreira",
            avatarURL: nil,
            bio: "Strength and CrossFit coach. Focused on performance and injury prevention.",
            specialties: [.strength, .crossfit],
            rating: 4.5,
            reviewCount: 43,
            hourlyRate: 110.0,
            location: TrainerLocation(city: "São Paulo", state: "SP", distanceKm: 4.1),
            isAvailable: true,
            isFeatured: false
        ),
        Trainer(
            id: "6",
            name: "Fernanda Rocha",
            avatarURL: nil,
            bio: "Pilates and stretching specialist with focus on posture correction.",
            specialties: [.pilates, .stretching, .yoga],
            rating: 4.9,
            reviewCount: 112,
            hourlyRate: 130.0,
            location: TrainerLocation(city: "São Paulo", state: "SP", distanceKm: 1.9),
            isAvailable: true,
            isFeatured: false
        )
    ]

    static let mockFeatured: [Trainer] = mockList.filter { $0.isFeatured }
    static let mockNearby: [Trainer] = mockList.sorted { ($0.location.distanceKm ?? 0) < ($1.location.distanceKm ?? 0) }
}
#endif
