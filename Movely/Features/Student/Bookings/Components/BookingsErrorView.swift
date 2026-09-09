//
//  BookingsErrorView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/09/26.
//

import Foundation
import SwiftUI

// MARK: - Bookings Error View
struct BookingsErrorView: View {

    // MARK: - Properties
    let message: String
    let onRetry: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: .movely.large) {
            Image(
                systemName: "exclamationmark.triangle.fill"
            )
            .font(.system(size: 48))
            .foregroundStyle(.movelyError)

            Text(message)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)

            MovelyButton("Try Again") {
                onRetry()
            }
        }
        .padding(
            .movely.screenPaddingHorizontal
        )
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

}
