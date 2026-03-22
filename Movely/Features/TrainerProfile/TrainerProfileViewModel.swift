//
//  TrainerProfileViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 17/03/26.
//

import Foundation
import SwiftUI

// MARK: - Trainer Profile View State
public enum TrainerProfileViewState: Equatable {
    case idle
    case loading
    case loaded(Trainer)
    case failure(String)
}

// MARK: - TrainerProfileViewModel
@Observable
@MainActor
public final class TrainerProfileViewModel {

    // MARK: - State
    public var viewState: TrainerProfileViewState = .idle

    // MARK: - Computed
    public var isLoading: Bool { viewState == .loading }

    public var trainer: Trainer? {
        if case .loaded(let trainer) = viewState { return trainer }
        return nil
    }

    public var errorMessage: String? {
        if case .failure(let message) = viewState { return message }
        return nil
    }

    // MARK: - Dependencies
    private let trainerId: String
    private let repository: TrainerRepositoryProtocol

    // MARK: - Init
    public init(trainerId: String, repository: TrainerRepositoryProtocol) {
        self.trainerId = trainerId
        self.repository = repository
    }

    // MARK: - Actions
    public func onAppear() async {
        guard viewState == .idle else { return }
        await fetchTrainer()
    }

    public func onRetry() async {
        viewState = .idle
        await fetchTrainer()
    }

    // MARK: - Private
    private func fetchTrainer() async {
        viewState = .loading

        do {
            let trainer = try await repository.fetchById(trainerId)
            viewState = .loaded(trainer)
        } catch let error as TrainerError {
            viewState = .failure(error.localizedDescription)
        } catch {
            viewState = .failure(error.localizedDescription)
        }
    }
}
