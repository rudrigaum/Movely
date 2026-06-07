//
//  TrainerDTO.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/05/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Trainer DTO
struct TrainerDTO: Codable {

    // MARK: - Properties
    let id: String
    let name: String
    let bio: String
    let specialties: [String]
    let rating: Double
    let reviewCount: Int
    let hourlyRate: Double
    let isAvailable: Bool
    let isFeatured: Bool
    let city: String
    let state: String
    let avatarURL: String?
    let createdAt: Timestamp

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case bio
        case specialties
        case rating
        case reviewCount
        case hourlyRate
        case isAvailable
        case isFeatured
        case city
        case state
        case avatarURL
        case createdAt
    }

    // MARK: - Mapping
    func toDomain() -> Trainer {
        Trainer(
            id: id,
            name: name,
            avatarURL: avatarURL,
            bio: bio,
            specialties: specialties.compactMap { TrainingCategory(rawValue: $0) },
            rating: rating,
            reviewCount: reviewCount,
            hourlyRate: hourlyRate,
            location: TrainerLocation(
                city: city,
                state: state,
                distanceKm: nil
            ),
            isAvailable: isAvailable,
            isFeatured: isFeatured
        )
    }

    static func fromDomain(_ trainer: Trainer) -> [String: Any] {
        var data: [String: Any] = [
            "id": trainer.id,
            "name": trainer.name,
            "bio": trainer.bio,
            "specialties": trainer.specialties.map { $0.rawValue },
            "rating": trainer.rating,
            "reviewCount": trainer.reviewCount,
            "hourlyRate": trainer.hourlyRate,
            "isAvailable": trainer.isAvailable,
            "isFeatured": trainer.isFeatured,
            "city": trainer.location.city,
            "state": trainer.location.state,
            "createdAt": Timestamp(date: Date())
        ]
        if let avatarURL = trainer.avatarURL {
            data["avatarURL"] = avatarURL
        }
        return data
    }
}
