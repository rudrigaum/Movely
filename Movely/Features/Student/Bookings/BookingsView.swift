//
//  BookingsView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

public struct BookingsView: View {
    public var body: some View {
        Text("Bookings")
            .font(.movely.title1)
            .foregroundStyle(.movelyTextPrimary)
            .movelyScreen()
    }
}

#Preview {
    BookingsView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}
