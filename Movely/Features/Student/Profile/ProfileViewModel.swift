//
//  ProfileViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 20/04/26.
//

import Foundation
import SwiftUI

// MARK: - Profile View State
public enum ProfileViewState: Equatable {
    case idle
    case loading
    case loaded
    case updating
    case failure(String)
}

// MARK: - ProfileViewModel
@Observable
@MainActor
public final class ProfileViewModel {

    // MARK: - State
    public var viewState: ProfileViewState = .idle
    public var isEditingName: Bool = false
    public var editingName: String = ""

    // MARK: - Computed
    public var isLoading: Bool { viewState == .loading }
    public var isUpdating: Bool { viewState == .updating }

    public var errorMessage: String? {
        if case .failure(let message) = viewState { return message }
        return nil
    }

    public var isEditNameValid: Bool {
        Validators.isValidName(editingName.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // MARK: - Dependencies
    private let updateUserUseCase: UpdateUserUseCaseProtocol
    private let authRepository: AuthRepositoryProtocol

    // MARK: - Init
    public init(
        updateUserUseCase: UpdateUserUseCaseProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.updateUserUseCase = updateUserUseCase
        self.authRepository = authRepository
    }

    // MARK: - Actions
    public func startEditingName(currentName: String) {
        editingName = currentName
        isEditingName = true
    }

    public func cancelEditingName() {
        editingName = ""
        isEditingName = false
        clearError()
    }

    public func updateName() async -> User? {
        guard isEditNameValid else { return nil }
        viewState = .updating

        do {
            let updatedUser = try await updateUserUseCase.execute(name: editingName)
            viewState = .loaded
            isEditingName = false
            editingName = ""
            return updatedUser
        } catch let error as UserError {
            viewState = .failure(error.localizedDescription)
            return nil
        } catch {
            viewState = .failure(error.localizedDescription)
            return nil
        }
    }

    public func signOut() async throws {
        try await authRepository.signOut()
    }

    public func clearError() {
        if case .failure = viewState {
            viewState = .loaded
        }
    }
}
