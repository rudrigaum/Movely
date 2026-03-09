//
//  MovelyApp.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 27/02/26.
//

import SwiftUI
import FirebaseCore

@main
struct MovelyApp: App {

    // MARK: - Dependencies
    @State private var environment: AppEnvironment

    // MARK: - Init
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] != nil {
            _environment = State(initialValue: AppEnvironment.mock())
            return
        }
        #endif
        FirebaseApp.configure()
        _environment = State(initialValue: AppEnvironment.production())
    }

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
        }
    }
}
