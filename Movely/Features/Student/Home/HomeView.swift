//
//  HomeView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

public struct HomeView: View {
    public var body: some View {
        Text("Home")
            .font(.movely.title1)
            .foregroundStyle(.movelyTextPrimary)
            .movelyScreen()
    }
}

#Preview {
    HomeView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}
