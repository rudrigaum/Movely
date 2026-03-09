//
//  ForgotPasswordView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Forgot Password View State
public enum ForgotPasswordViewState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

// MARK: - ForgotPasswordViewModel
@Observable
@MainActor
public final class ForgotPasswordViewModel {

    // MARK: - Input
    public var email: String = ""

    // MARK: - State
    public var viewState: ForgotPasswordViewState = .idle

    // MARK: - Computed
    public var isFormValid: Bool {
        Validators.isValidEmail(email)
    }

    public var isLoading: Bool {
        viewState == .loading
    }

    public var errorMessage: String? {
        if case .failure(let message) = viewState { return message }
        return nil
    }

    // MARK: - Dependencies
    private let repository: AuthRepositoryProtocol

    // MARK: - Init
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions
    public func sendResetEmail() async {
        guard isFormValid else { return }
        viewState = .loading

        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            viewState = .success
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

// MARK: - Forgot Password View
public struct ForgotPasswordView: View {

    // MARK: - Dependencies
    @State private var viewModel: ForgotPasswordViewModel
    private let router: AuthRouter

    // MARK: - Init
    public init(router: AuthRouter) {
        self.router = router
        self._viewModel = State(
            initialValue: ForgotPasswordViewModel(
                repository: AuthRepositoryMock()
            )
        )
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: .movely.xLarge) {
                if viewModel.viewState == .success {
                    successSection
                } else {
                    formSection
                }
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.top, .movely.xxxLarge)
            .padding(.bottom, .movely.xxLarge)
        }
        .movelyScreen()
        .navigationBarBackButtonHidden()
        .toolbar { backButton }
        .onTapGesture { hideKeyboard() }
        .animation(.easeInOut, value: viewModel.viewState)
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: .movely.xLarge) {
            headerSection

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

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                }

                MovelyButton(
                    "Send Reset Link",
                    isLoading: viewModel.isLoading
                ) {
                    Task { await viewModel.sendResetEmail() }
                }
                .disabled(!viewModel.isFormValid)
                .opacity(viewModel.isFormValid ? 1.0 : 0.6)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: .movely.small) {
            Image(systemName: "lock.rotation")
                .font(.system(size: 64))
                .foregroundStyle(.movelyPrimary)

            Text("Reset Password")
                .font(.movely.title1)
                .foregroundStyle(.movelyTextPrimary)

            Text("Enter your email and we'll send you a link to reset your password.")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Success Section
    private var successSection: some View {
        VStack(spacing: .movely.xLarge) {
            VStack(spacing: .movely.small) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.movelySuccess)

                Text("Email Sent!")
                    .font(.movely.title1)
                    .foregroundStyle(.movelyTextPrimary)

                Text("Check your inbox and follow the instructions to reset your password.")
                    .font(.movely.subheadline)
                    .foregroundStyle(.movelyTextSecondary)
                    .multilineTextAlignment(.center)
            }

            MovelyButton("Back to Sign In") {
                router.navigateToRoot()
            }
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
        guard !viewModel.email.isEmpty else { return .idle }
        return Validators.isValidEmail(viewModel.email) ? .success : .error(message: "Please enter a valid email.")
    }

    // MARK: - Back Button
    private var backButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                router.navigateBack()
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundStyle(.movelyTextPrimary)
            }
        }
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
#Preview("Forgot Password - Idle") {
    NavigationStack {
        ForgotPasswordView(router: AuthRouter())
            .environment(AppEnvironment.mock())
    }
}

#Preview("Forgot Password - Dark") {
    NavigationStack {
        ForgotPasswordView(router: AuthRouter())
            .environment(AppEnvironment.mock())
            .preferredColorScheme(.dark)
    }
}
