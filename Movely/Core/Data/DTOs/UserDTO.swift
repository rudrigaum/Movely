//
//  UserDTO.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 04/05/26.
//

import Foundation
import FirebaseFirestore
import Foundation

// MARK: - User DTO
struct UserDTO: Codable {

    // MARK: - Properties
    let id: String
    let name: String
    let email: String
    let role: String
    let avatarURL: String?
    let createdAt: Timestamp

    // MARK: - Firestore Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case role
        case avatarURL
        case createdAt
    }

    // MARK: - Mapping
    func toDomain() -> User {
        User(
            id: id,
            name: name,
            email: email,
            role: UserRole(rawValue: role) ?? .student,
            avatarURL: avatarURL,
            createdAt: createdAt.dateValue()
        )
    }

    static func fromDomain(_ user: User) -> [String: Any] {
        var data: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "role": user.role.rawValue,
            "createdAt": Timestamp(date: user.createdAt)
        ]
        if let avatarURL = user.avatarURL {
            data["avatarURL"] = avatarURL
        }
        return data
    }
}
