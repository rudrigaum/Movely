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

    // MARK: - Init
    init() {
        FirebaseApp.configure()
    }

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
