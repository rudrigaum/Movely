//
//  BookingsFilterPicker.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/09/26.
//

import Foundation
import SwiftUI

// MARK: - Bookings Filter Picker

struct BookingsFilterPicker: View {

    // MARK: - Properties

    @Binding var selection: BookingTab

    // MARK: - Body

    var body: some View {
        Picker(
            "Bookings Filter",
            selection: $selection
        ) {
            ForEach(
                BookingTab.allCases,
                id: \.self
            ) { tab in
                Text(tab.rawValue)
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(
            .horizontal,
            .movely.screenPaddingHorizontal
        )
        .padding(
            .vertical,
            .movely.small
        )
    }

}
