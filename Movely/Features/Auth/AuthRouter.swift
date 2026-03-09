//
//  AuthRouter.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation

import SwiftUI

// MARK: - Auth Route
public enum AuthRoute: Hashable {
    case login
    case register
    case forgotPassword
}

// MARK: - Auth Router
@Observable
public final class AuthRouter {

    // MARK: - Properties
    public var path: NavigationPath = NavigationPath()

    // MARK: - Navigation Actions
    public func navigate(to route: AuthRoute) {
        path.append(route)
    }

    public func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func navigateToRoot() {
        path = NavigationPath()
    }
}

// MARK: - Auth Flow View
public struct AuthFlowView: View {

    // MARK: - Dependencies
    @State private var router = AuthRouter()
    @Environment(AppEnvironment.self) private var env

    // MARK: - Body
    public var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(router: router)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView(router: router)
                    case .register:
                        Text("Register — Coming soon")
                    case .forgotPassword:
                        Text("Forgot Password — Coming soon")
                    }
                }
        }
    }
}

// MARK: - Preview
#Preview("Auth Flow") {
    AuthFlowView()
        .environment(AppEnvironment.mock())
}
