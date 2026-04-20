//
//  AuthRepositoryProtocol.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation

// MARK: - Auth Repository Protocol
public protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(name: String, email: String, password: String, role: UserRole) async throws -> User
    func signOut() async throws
    var currentUser: User? { get }
}

// MARK: - Auth Error
public enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case wrongPassword
    case emailAlreadyInUse
    case weakPassword
    case userNotFound
    case networkError
    case unknown(message: String)

    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .emailAlreadyInUse:
            return "This email is already registered. Try signing in."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .userNotFound:
            return "No account found with this email."
        case .networkError:
            return "Connection error. Please check your internet."
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Mock
#if DEBUG
final class AuthRepositoryMock: AuthRepositoryProtocol {

    var currentUser: User?
    var shouldFail = false

    func signIn(email: String, password: String) async throws -> User {
        if shouldFail { throw AuthError.wrongPassword }
        try await Task.sleep(nanoseconds: 1_000_000_000)
        currentUser = .mockStudent
        return .mockStudent
    }

    func signUp(
        name: String,
        email: String,
        password: String,
        role: UserRole
    ) async throws -> User {
        if shouldFail { throw AuthError.emailAlreadyInUse }
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let user = User(id: "new-user-001", name: name, email: email, role: role)
        currentUser = user
        return user
    }

    func signOut() async throws {
        if shouldFail { throw AuthError.unknown(message: "Sign out failed.") }
        currentUser = nil
    }
}
#endif
