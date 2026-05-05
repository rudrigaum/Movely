//
//  UserRepository.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/05/26.
//

import Foundation
import FirebaseFirestore

// MARK: - User Repository
final class UserRepository: UserRepositoryProtocol {

    // MARK: - Properties
    private let dataBase = Firestore.firestore()
    private let collection = "users"

    // MARK: - Protocol
    func fetchCurrentUser() async throws -> User {
        guard let userId = AuthRepository.currentUserId else {
            throw UserError.notFound
        }

        do {
            let snapshot = try await dataBase
                .collection(collection)
                .document(userId)
                .getDocument()

            guard snapshot.exists,
                  let dto = try? snapshot.data(as: UserDTO.self) else {
                throw UserError.notFound
            }

            return dto.toDomain()
        } catch let error as UserError {
            throw error
        } catch {
            throw UserError.networkError
        }
    }

    func updateName(_ name: String) async throws -> User {
        guard let userId = AuthRepository.currentUserId else {
            throw UserError.notFound
        }

        do {
            try await dataBase
                .collection(collection)
                .document(userId)
                .updateData(["name": name])

            return try await fetchCurrentUser()
        } catch let error as UserError {
            throw error
        } catch {
            throw UserError.updateFailed
        }
    }
}
