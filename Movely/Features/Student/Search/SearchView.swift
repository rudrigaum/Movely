//
//  SearchView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

public struct SearchView: View {
    public var body: some View {
        Text("Search")
            .font(.movely.title1)
            .foregroundStyle(.movelyTextPrimary)
            .movelyScreen()
    }
}

#Preview {
    SearchView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}
