//
//  TrainerRepository.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/05/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Trainer Repository
final class TrainerRepository: TrainerRepositoryProtocol {

    // MARK: - Properties
    private let dataBase = Firestore.firestore()
    private let collection = "trainers"

    // MARK: - Protocol
    func fetchFeatured() async throws -> [Trainer] {
        do {
            let snapshot = try await dataBase
                .collection(collection)
                .whereField("isFeatured", isEqualTo: true)
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "rating", descending: true)
                .limit(to: 10)
                .getDocuments()

            return snapshot.documents.compactMap { document in
                try? document.data(as: TrainerDTO.self)
            }.map { $0.toDomain() }
        } catch {
            throw TrainerError.networkError
        }
    }

    func fetchNearby(limit: Int) async throws -> [Trainer] {
        do {
            let snapshot = try await dataBase
                .collection(collection)
                .whereField("isAvailable", isEqualTo: true)
                .order(by: "rating", descending: true)
                .limit(to: limit)
                .getDocuments()

            return snapshot.documents.compactMap { document in
                try? document.data(as: TrainerDTO.self)
            }.map { $0.toDomain() }
        } catch {
            throw TrainerError.networkError
        }
    }

    func fetchByCategory(_ category: TrainingCategory) async throws -> [Trainer] {
        do {
            let snapshot = try await dataBase
                .collection(collection)
                .whereField("specialties", arrayContains: category.rawValue)
                .order(by: "rating", descending: true)
                .getDocuments()

            return snapshot.documents.compactMap { document in
                try? document.data(as: TrainerDTO.self)
            }.map { $0.toDomain() }
        } catch {
            throw TrainerError.networkError
        }
    }

    func fetchById(_ id: String) async throws -> Trainer {
        do {
            let snapshot = try await dataBase
                .collection(collection)
                .document(id)
                .getDocument()

            guard snapshot.exists,
                  let dto = try? snapshot.data(as: TrainerDTO.self) else {
                throw TrainerError.notFound
            }

            return dto.toDomain()
        } catch let error as TrainerError {
            throw error
        } catch {
            throw TrainerError.networkError
        }
    }
}
