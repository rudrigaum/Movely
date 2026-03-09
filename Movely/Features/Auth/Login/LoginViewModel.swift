//
//  LoginViewModel.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation
import SwiftUI

// MARK: - Login View State
public enum LoginViewState: Equatable {
    case idle
    case loading
    case success(User)
    case failure(String)
}

// MARK: - LoginViewModel
@Observable
@MainActor
public final class LoginViewModel {

    // MARK: - Input
    public var email: String = ""
    public var password: String = ""

    // MARK: - State
    public var viewState: LoginViewState = .idle

    // MARK: - Computed
    public var isFormValid: Bool {
        Validators.isValidEmail(email) && !password.isEmpty
    }

    public var isLoading: Bool {
        viewState == .loading
    }

    public var errorMessage: String? {
        if case .failure(let message) = viewState { return message }
        return nil
    }

    // MARK: - Dependencies
    private let signInUseCase: SignInUseCaseProtocol

    // MARK: - Init
    public init(signInUseCase: SignInUseCaseProtocol) {
        self.signInUseCase = signInUseCase
    }

    // MARK: - Actions
    public func signIn() async {
        guard isFormValid else { return }
        viewState = .loading

        do {
            let user = try await signInUseCase.execute(
                email: email,
                password: password
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
