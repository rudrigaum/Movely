//
//  RootView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Root View
public struct RootView: View {

    // MARK: - Dependencies
    @Environment(AppEnvironment.self) private var env

    // MARK: - Body
    public var body: some View {
        Group {
            if env.isAuthenticated {
                MainTabView()
            } else {
                AuthFlowView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: env.isAuthenticated)
    }
}

// MARK: - Preview
#Preview("Root - Unauthenticated") {
    RootView()
        .environment(AppEnvironment.mock(isAuthenticated: false))
}

#Preview("Root - Authenticated") {
    RootView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}
