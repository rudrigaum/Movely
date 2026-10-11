//
//  BookingsFilterPicker.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/09/26.
//

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

// MARK: - Preview
#if DEBUG

private struct BookingsFilterPickerPreview: View {

    // MARK: - State
    @State private var selection: BookingTab

    // MARK: - Initialization
    init(
        selection: BookingTab = .upcoming
    ) {
        _selection = State(
            initialValue: selection
        )
    }

    // MARK: - Body
    var body: some View {
        BookingsFilterPicker(
            selection: $selection
        )
        .movelyScreen()
    }

}

#Preview("Upcoming") {
    BookingsFilterPickerPreview(
        selection: .upcoming
    )
}

#Preview("Past") {
    BookingsFilterPickerPreview(
        selection: .past
    )
}

#Preview("Dark") {
    BookingsFilterPickerPreview(
        selection: .upcoming
    )
    .preferredColorScheme(.dark)
}

#endif
