//
//  AuthRepository.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation
import FirebaseAuth

// MARK: - Auth Repository
public final class AuthRepository: AuthRepositoryProtocol {

    // MARK: - Properties
    public var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return firebaseUser.toUser()
    }

    // MARK: - Sign In
    public func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.toUser()
        } catch let error as NSError {
            throw error.toAuthError()
        }
    }

    // MARK: - Sign Up
    public func signUp(
        name: String,
        email: String,
        password: String,
        role: UserRole
    ) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()

            return User(
                id: result.user.uid,
                name: name,
                email: email,
                role: role
            )
        } catch let error as NSError {
            throw error.toAuthError()
        }
    }

    // MARK: - Sign Out
    public func signOut() async throws {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            throw error.toAuthError()
        }
    }
}

// MARK: - FirebaseAuth Mappers
private extension FirebaseAuth.User {
    func toUser() -> User {
        User(
            id: uid,
            name: displayName ?? "User",
            email: email ?? "",
            role: .student
        )
    }
}

private extension NSError {
    func toAuthError() -> AuthError {
        guard let code = AuthErrorCode(rawValue: self.code) else {
            return .unknown(message: localizedDescription)
        }
        switch code {
        case .invalidEmail: return .invalidEmail
        case .wrongPassword: return .wrongPassword
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .weakPassword: return .weakPassword
        case .userNotFound: return .userNotFound
        case .networkError: return .networkError
        default: return .unknown(message: localizedDescription)
        }
    }
}
