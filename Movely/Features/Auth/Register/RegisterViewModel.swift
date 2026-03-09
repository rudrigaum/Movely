//
//  RegisterViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation
import SwiftUI

// MARK: - Register View State
public enum RegisterViewState: Equatable {
    case idle
    case loading
    case success(User)
    case failure(String)
}

// MARK: - RegisterViewModel
@Observable
@MainActor
public final class RegisterViewModel {

    // MARK: - Input
    public var name: String = ""
    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public var selectedRole: UserRole = .student

    // MARK: - State
    public var viewState: RegisterViewState = .idle

    // MARK: - Computed
    public var isFormValid: Bool {
        Validators.isValidName(name) &&
        Validators.isValidEmail(email) &&
        Validators.isValidPassword(password) &&
        password == confirmPassword
    }

    public var isLoading: Bool {
        viewState == .loading
    }

    public var errorMessage: String? {
        if case .failure(let message) = viewState { return message }
        return nil
    }

    public var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }

    public var confirmPasswordState: MovelyTextFieldState {
        guard !confirmPassword.isEmpty else { return .idle }
        return passwordsMatch ? .success : .error(message: "Passwords don't match.")
    }

    // MARK: - Dependencies
    private let signUpUseCase: SignUpUseCaseProtocol

    // MARK: - Init
    public init(signUpUseCase: SignUpUseCaseProtocol) {
        self.signUpUseCase = signUpUseCase
    }

    // MARK: - Actions
    public func signUp() async {
        guard isFormValid else { return }
        viewState = .loading

        do {
            let user = try await signUpUseCase.execute(
                name: name,
                email: email,
                password: password,
                role: selectedRole
            )
            viewState = .success(user)
        } catch let error as AuthError {
            viewState = .failure(error.localizedDescription)
        } catch {
            viewState = .failure(error.localizedDescription)
        }
    }

    public func clearError() {
        if case .failure = viewState {
            viewState = .idle
        }
    }
}
