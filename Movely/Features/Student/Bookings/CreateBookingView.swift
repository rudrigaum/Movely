//
//  CreateBookingView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/06/26.
//

import Foundation
import SwiftUI

public struct CreateBookingView: View {

    // MARK: - Dependencies
    @State private var viewModel: CreateBookingViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization
    public init(viewModel: CreateBookingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .movely.xLarge) {
                dateSection
                notesSection
                Spacer()
                bookingButton
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.vertical, .movely.large)
        }
        .movelyScreen()
        .navigationTitle("Book Session")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.state) { _, newState in
            if newState == .success {
                dismiss()
            }
        }
        .alert("Booking Error", isPresented: Binding(
            get: { if case .failure = viewModel.state { return true } else { return false } },
            set: { _ in viewModel.state = .idle }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if case let .failure(message) = viewModel.state {
                Text(message)
            }
        }
    }

    // MARK: - Date Section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            Label("Select Date & Time", systemImage: "calendar")
                .font(.movely.headline)
                .foregroundStyle(.movelyTextPrimary)

            DatePicker(
                "Training Date",
                selection: $viewModel.selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(.movelyPrimary)
            .background(.movelyBackgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: .movely.radiusMedium))
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: .movely.small) {
            Label("Notes (Optional)", systemImage: "note.text")
                .font(.movely.headline)
                .foregroundStyle(.movelyTextPrimary)

            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
                .padding(.movely.small)
                .font(.movely.body)
                .scrollContentBackground(.hidden)
                .background(.movelyBackgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: .movely.radiusMedium))
                .overlay(
                    RoundedRectangle(cornerRadius: .movely.radiusMedium)
                        .strokeBorder(.movelyBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Booking Button
    private var bookingButton: some View {
        Button {
            Task { await viewModel.createBooking() }
        } label: {
            HStack {
                if viewModel.state == .loading {
                    ProgressView()
                        .tint(.white)
                        .padding(.trailing, .movely.tiny)
                }
                Text(viewModel.state == .loading ? "Booking..." : "Confirm Booking")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.movelyPrimary)
        .disabled(viewModel.state == .loading)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        CreateBookingView(
            viewModel: CreateBookingViewModel(
                trainerId: "trainer_1",
                studentId: "student_1",
                createBookingUseCase: AppEnvironment.mock().createBookingUseCase
            )
        )
    }
}
#endif
