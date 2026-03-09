//
//  RegisterView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Register View
public struct RegisterView: View {

    // MARK: - Dependencies
    @State private var viewModel: RegisterViewModel
    @Environment(AppEnvironment.self) private var env
    private let router: AuthRouter

    // MARK: - Init
    public init(router: AuthRouter) {
        self.router = router
        self._viewModel = State(
            initialValue: RegisterViewModel(
                signUpUseCase: SignUpUseCaseMock()
            )
        )
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: .movely.xLarge) {
                headerSection
                roleSection
                formSection
                footerSection
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.top, .movely.large)
            .padding(.bottom, .movely.xxLarge)
        }
        .movelyScreen()
        .navigationBarBackButtonHidden()
        .toolbar { backButton }
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
            Text("Create account")
                .font(.movely.title1)
                .foregroundStyle(.movelyTextPrimary)

            Text("Join Movely and start your fitness journey")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Role Section
    private var roleSection: some View {
        VStack(alignment: .leading, spacing: .movely.tiny) {
            Text("I am a...")
                .font(.movely.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.movelyTextPrimary)

            HStack(spacing: .movely.small) {
                RoleCard(
                    title: "Student",
                    subtitle: "Find and book trainers",
                    icon: "figure.run",
                    isSelected: viewModel.selectedRole == .student
                ) {
                    viewModel.selectedRole = .student
                }

                RoleCard(
                    title: "Trainer",
                    subtitle: "Offer your services",
                    icon: "figure.strengthtraining.traditional",
                    isSelected: viewModel.selectedRole == .trainer
                ) {
                    viewModel.selectedRole = .trainer
                }
            }
        }
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: .movely.small) {
            MovelyTextField(
                "Full Name",
                placeholder: "Your full name",
                text: Binding(
                    get: { viewModel.name },
                    set: { viewModel.name = $0 }
                ),
                state: nameFieldState,
                leadingIcon: "person"
            )

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
                leadingIcon: "lock",
                isSecure: true
            )

            MovelyTextField(
                "Confirm Password",
                placeholder: "Repeat your password",
                text: Binding(
                    get: { viewModel.confirmPassword },
                    set: { viewModel.confirmPassword = $0 }
                ),
                state: viewModel.confirmPasswordState,
                leadingIcon: "lock.fill",
                isSecure: true
            )

            if let errorMessage = viewModel.errorMessage {
                errorBanner(message: errorMessage)
            }

            MovelyButton(
                "Create Account",
                isLoading: viewModel.isLoading
            ) {
                Task { await viewModel.signUp() }
            }
            .disabled(!viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1.0 : 0.6)
        }
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        HStack(spacing: .movely.micro) {
            Text("Already have an account?")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)

            Button("Sign In") {
                router.navigateBack()
            }
            .font(.movely.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.movelyPrimary)
        }
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
    private var nameFieldState: MovelyTextFieldState {
        guard !viewModel.name.isEmpty else { return .idle }
        return Validators.isValidName(viewModel.name) ? .success : .error(message: "Name must be at least 2 characters.")
    }

    private var emailFieldState: MovelyTextFieldState {
        guard !viewModel.email.isEmpty else { return .idle }
        return Validators.isValidEmail(viewModel.email) ? .success : .error(message: "Please enter a valid email.")
    }
}

// MARK: - Role Card
private struct RoleCard: View {

    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: .movely.tiny) {
                Image(systemName: icon)
                    .font(.system(size: .movely.iconLarge))
                    .foregroundStyle(isSelected ? .movelyPrimary : .movelyTextSecondary)

                Text(title)
                    .font(.movely.headline)
                    .foregroundStyle(isSelected ? .movelyPrimary : .movelyTextPrimary)

                Text(subtitle)
                    .font(.movely.caption1)
                    .foregroundStyle(.movelyTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.movely.medium)
            .background(isSelected ? .movelyPrimary.opacity(0.08) : .movelyBackgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: .movely.radiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: .movely.radiusLarge)
                    .strokeBorder(
                        isSelected ? .movelyPrimary : .movelyBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(MovelyPressButtonStyle())
    }
}

// MARK: - Press Button Style
private struct MovelyPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
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
#Preview("Register - Idle") {
    NavigationStack {
        RegisterView(router: AuthRouter())
            .environment(AppEnvironment.mock())
    }
}

#Preview("Register - Dark") {
    NavigationStack {
        RegisterView(router: AuthRouter())
            .environment(AppEnvironment.mock())
            .preferredColorScheme(.dark)
    }
}
