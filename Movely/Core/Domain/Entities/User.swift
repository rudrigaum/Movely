//
//  User.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation

// MARK: - User Role
public enum UserRole: String, Codable {
    case student
    case trainer
}

// MARK: - User Entity
public struct User: Equatable {

    // MARK: - Properties
    public let id: String
    public let name: String
    public let email: String
    public let role: UserRole
    public let avatarURL: String?
    public let createdAt: Date

    // MARK: - Init
    public init(
        id: String,
        name: String,
        email: String,
        role: UserRole,
        avatarURL: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }
}

// MARK: - Mock
#if DEBUG
extension User {
    static let mockStudent = User(
        id: "mock-student-001",
        name: "Rodrigo Cerqueira",
        email: "rodrigo@movely.com",
        role: .student
    )

    static let mockTrainer = User(
        id: "mock-trainer-001",
        name: "Carlos Silva",
        email: "carlos@movely.com",
        role: .trainer
    )
}
#endif
