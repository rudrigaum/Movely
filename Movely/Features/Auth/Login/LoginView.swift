//
//  LoginView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation
import SwiftUI

// MARK: - Login View
public struct LoginView: View {

    // MARK: - Dependencies
    @State private var viewModel: LoginViewModel
    @Environment(AppEnvironment.self) private var env
    private let router: AuthRouter

    // MARK: - Init
    public init(router: AuthRouter) {
        self.router = router
        self._viewModel = State(
            initialValue: LoginViewModel(
                signInUseCase: SignInUseCaseMock()
            )
        )
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: .movely.xxLarge) {
                headerSection
                formSection
                footerSection
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.top, .movely.xxxLarge)
            .padding(.bottom, .movely.xxLarge)
        }
        .movelyScreen()
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.viewState) { _, newState in
            if case .success(let user) = newState {
                env.currentUser = user
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: .movely.small) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.movelyPrimary)

            Text("Welcome back")
                .font(.movely.title1)
                .foregroundStyle(.movelyTextPrimary)

            Text("Sign in to continue your fitness journey")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: .movely.small) {
            MovelyTextField(
                "Email",
                placeholder: "you@example.com",
                text: Binding(
                    get: { viewModel.email },
                    set: { viewModel.email = $0 }
                ),
                state: emailFieldState,
                leadingIcon: "envelope",
                keyboardType: .emailAddress
            )

            MovelyTextField(
                "Password",
                placeholder: "Min. 6 characters",
                text: Binding(
                    get: { viewModel.password },
                    set: { viewModel.password = $0 }
                ),
                state: passwordFieldState,
                leadingIcon: "lock",
                isSecure: true
            )

            if let errorMessage = viewModel.errorMessage {
                errorBanner(message: errorMessage)
            }

            forgotPasswordButton

            MovelyButton(
                "Sign In",
                isLoading: viewModel.isLoading,
                isFullWidth: true
            ) {
                Task { await viewModel.signIn() }
            }
            .disabled(!viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1.0 : 0.6)
        }
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: .movely.micro) {
            Text("Don't have an account?")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)

            Button("Sign Up") {
                router.navigate(to: .register)
            }
            .font(.movely.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.movelyPrimary)
        }
    }

    // MARK: - Forgot Password Button
    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button("Forgot password?") {
                router.navigate(to: .forgotPassword)
            }
            .font(.movely.subheadline)
            .foregroundStyle(.movelyPrimary)
        }
    }

    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(spacing: .movely.tiny) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.movelyError)
            Text(message)
                .font(.movely.caption1)
                .foregroundStyle(.movelyError)
            Spacer()
            Button {
                viewModel.clearError()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundStyle(.movelyTextSecondary)
            }
        }
        .padding(.movely.small)
        .background(.movelyError.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: .movely.radiusMedium))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Field States
    private var emailFieldState: MovelyTextFieldState {
        if let error = viewModel.errorMessage, error.contains("email") {
            return .error(message: error)
        }
        if !viewModel.email.isEmpty && Validators.isValidEmail(viewModel.email) {
            return .success
        }
        return .idle
    }

    private var passwordFieldState: MovelyTextFieldState {
        if let error = viewModel.errorMessage, error.contains("password") {
            return .error(message: error)
        }
        return .idle
    }
}

// MARK: - Keyboard Helper
private extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Preview
#Preview("Login - Idle") {
    NavigationStack {
        LoginView(router: AuthRouter())
            .environment(AppEnvironment.mock())
    }
}

#Preview("Login - Loading") {
    let env = AppEnvironment.mock()
    let router = AuthRouter()
    NavigationStack {
        LoginView(router: router)
            .environment(env)
    }
}

#Preview("Login - Error") {
    NavigationStack {
        LoginView(router: AuthRouter())
            .environment(AppEnvironment.mock(shouldFail: true))
    }
}
