//
//  ProfileView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Profile View
public struct ProfileView: View {

    // MARK: - Dependencies
    @State private var viewModel: ProfileViewModel?
    @Environment(AppEnvironment.self) private var env

    public init() {}

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .movely.xLarge) {
                    if let viewModel {
                        avatarSection(viewModel: viewModel)
                        infoSection(viewModel: viewModel)
                        actionsSection(viewModel: viewModel)
                    }
                }
                .padding(.horizontal, .movely.screenPaddingHorizontal)
                .padding(.vertical, .movely.xLarge)
            }
            .movelyScreen()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(
                    updateUserUseCase: env.updateUserUseCase,
                    authRepository: env.authRepository
                )
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.isEditingName ?? false },
            set: { if !$0 { viewModel?.cancelEditingName() } }
        )) {
            if let viewModel {
                editNameSheet(viewModel: viewModel)
            }
        }
    }

    // MARK: - Avatar Section
    private func avatarSection(viewModel: ProfileViewModel) -> some View {
        VStack(spacing: .movely.medium) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.movelyPrimary.opacity(0.8), .movelyPrimary.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: .movely.avatarXLarge, height: .movely.avatarXLarge)

                Text(env.currentUser?.name.prefix(1) ?? "?")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: .movely.micro) {
                Text(env.currentUser?.name ?? "")
                    .font(.movely.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.movelyTextPrimary)

                Text(env.currentUser?.email ?? "")
                    .font(.movely.subheadline)
                    .foregroundStyle(.movelyTextSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if let role = env.currentUser?.role {
                    RoleBadge(role: role)
                }
            }
        }
    }

    // MARK: - Info Section
    private func infoSection(viewModel: ProfileViewModel) -> some View {
        MovelyCard {
            VStack(spacing: 0) {
                ProfileRow(
                    icon: "person.fill",
                    title: "Full Name",
                    value: env.currentUser?.name ?? ""
                ) {
                    viewModel.startEditingName(
                        currentName: env.currentUser?.name ?? ""
                    )
                }

                Divider().padding(.leading, 44)

                ProfileRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: env.currentUser?.email ?? "",
                    action: nil
                )

                Divider().padding(.leading, 44)

                ProfileRow(
                    icon: "calendar",
                    title: "Member since",
                    value: env.currentUser?.createdAt.formatted(.dateTime.month(.wide).year()) ?? "",
                    action: nil
                )
            }
        }
    }

    // MARK: - Actions Section
    private func actionsSection(viewModel: ProfileViewModel) -> some View {
        VStack(spacing: .movely.small) {
            if let errorMessage = viewModel.errorMessage {
                errorBanner(message: errorMessage, viewModel: viewModel)
            }

            MovelyButton(
                "Sign Out",
                variant: .destructive,
                isFullWidth: true
            ) {
                Task {
                    try? await viewModel.signOut()
                    env.currentUser = nil
                }
            }
        }
    }

    // MARK: - Edit Name Sheet
    private func editNameSheet(viewModel: ProfileViewModel) -> some View {
        NavigationStack {
            VStack(spacing: .movely.xLarge) {
                MovelyTextField(
                    "Full Name",
                    placeholder: "Your full name",
                    text: Binding(
                        get: { viewModel.editingName },
                        set: { viewModel.editingName = $0 }
                    ),
                    state: nameFieldState(viewModel: viewModel),
                    leadingIcon: "person"
                )
                .padding(.horizontal, .movely.screenPaddingHorizontal)

                Spacer()
            }
            .padding(.top, .movely.large)
            .movelyScreen()
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.cancelEditingName()
                    }
                    .foregroundStyle(.movelyTextSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    MovelyButton(
                        "Save",
                        size: .small,
                        isLoading: viewModel.isUpdating
                    ) {
                        Task {
                            if let updatedUser = await viewModel.updateName() {
                                env.currentUser = updatedUser
                            }
                        }
                    }
                    .disabled(!viewModel.isEditNameValid)
                    .opacity(viewModel.isEditNameValid ? 1.0 : 0.6)
                }
            }
        }
        .presentationDetents([.height(200)])
    }

    // MARK: - Error Banner
    private func errorBanner(message: String, viewModel: ProfileViewModel) -> some View {
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
    }

    // MARK: - Field States
    private func nameFieldState(viewModel: ProfileViewModel) -> MovelyTextFieldState {
        guard !viewModel.editingName.isEmpty else { return .idle }
        return viewModel.isEditNameValid
        ? .success
        : .error(message: "Name must be at least 2 characters.")
    }

    // MARK: - Role Badge
    private struct RoleBadge: View {
        let role: UserRole

        var body: some View {
            Text(role.rawValue.capitalized)
                .font(.movely.caption1)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyPrimary)
                .padding(.horizontal, .movely.small)
                .padding(.vertical, .movely.micro)
                .background(.movelyPrimary.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    // MARK: - Profile Row
    private struct ProfileRow: View {
        let icon: String
        let title: String
        let value: String
        let action: (() -> Void)?

        var body: some View {
            Button {
                action?()
            } label: {
                HStack(spacing: .movely.small) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(.movelyPrimary)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.movely.caption1)
                            .foregroundStyle(.movelyTextSecondary)
                        Text(value)
                            .font(.movely.subheadline)
                            .foregroundStyle(.movelyTextPrimary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Spacer()

                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.movelyTextSecondary)
                    }
                }
                .padding(.movely.medium)
            }
            .disabled(action == nil)
        }
    }

    // MARK: - Preview
    #Preview("Profile - Student") {
        ProfileView()
            .environment(AppEnvironment.mock(isAuthenticated: true))
    }

    #Preview("Profile - Dark") {
        ProfileView()
            .environment(AppEnvironment.mock(isAuthenticated: true))
            .preferredColorScheme(.dark)
    }
}
