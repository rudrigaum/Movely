//
//  BookingsLoadingView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/09/26.
//

import Foundation
import SwiftUI

// MARK: - Bookings Loading View
struct BookingsLoadingView: View {

    // MARK: - Constants
    private enum Constants {

        static let skeletonCount = 4
        static let skeletonHeight: CGFloat = 120

    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .movely.medium) {
                ForEach(
                    0..<Constants.skeletonCount,
                    id: \.self
                ) { _ in
                    skeleton
                }
            }
            .padding(
                .horizontal,
                .movely.screenPaddingHorizontal
            )
            .padding(
                .top,
                .movely.medium
            )
        }
    }

    // MARK: - Skeleton
    private var skeleton: some View {
        RoundedRectangle(
            cornerRadius: .movely.radiusLarge
        )
        .fill(.movelyBackgroundElevated)
        .frame(
            height: Constants.skeletonHeight
        )
        .movelyShimmer(
            isLoading: true
        )
    }

}
