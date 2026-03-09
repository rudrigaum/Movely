//
//  ProfileView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

public struct ProfileView: View {

    @Environment(AppEnvironment.self) private var env

    public var body: some View {
        VStack(spacing: .movely.large) {
            Text("Profile")
                .font(.movely.title1)
                .foregroundStyle(.movelyTextPrimary)

            MovelyButton("Sign Out", variant: .destructive) {
                Task {
                    try? await env.authRepository.signOut()
                    env.currentUser = nil
                }
            }
        }
        .movelyScreen()
    }
}

#Preview {
    ProfileView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}
