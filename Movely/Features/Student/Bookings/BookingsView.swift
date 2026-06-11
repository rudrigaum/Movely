//
//  BookingsView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Booking Tab Enum
private enum BookingTab: String, CaseIterable {
    case upcoming = "Upcoming"
    case past = "Past"
}

// MARK: - Bookings View
public struct BookingsView: View {

    // MARK: - Dependencies
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel: BookingsViewModel?

    // MARK: - State
    @State private var selectedTab: BookingTab = .upcoming

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Bookings Filter", selection: $selectedTab) {
                    ForEach(BookingTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, .movely.screenPaddingHorizontal)
                .padding(.vertical, .movely.small)

                Group {
                    if let viewModel {
                        contentBody(for: viewModel)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .movelyScreen()
            .navigationTitle("My Bookings")
            .task {
                if viewModel == nil, let studentId = env.currentUser?.id {
                    viewModel = BookingsViewModel(
                        studentId: studentId,
                        fetchBookingsUseCase: env.fetchStudentBookingsUseCase
                    )
                    await viewModel?.onAppear()
                }
            }
        }
    }

    // MARK: - Content Body
    @ViewBuilder
    private func contentBody(for viewModel: BookingsViewModel) -> some View {
        switch viewModel.viewState {
        case .idle, .loading:
            loadingSection
        case .loaded(let upcoming, let past):
            let targetList = selectedTab == .upcoming ? upcoming : past

            if targetList.isEmpty {
                emptyStateSection
            } else {
                bookingsList(bookings: targetList, viewModel: viewModel)
            }

        case .failure(let message):
            errorSection(message: message, viewModel: viewModel)
        }
    }

    // MARK: - Bookings List
    private func bookingsList(bookings: [Booking], viewModel: BookingsViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: .movely.medium) {
                ForEach(bookings) { booking in
                    BookingCard(booking: booking)
                }
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.vertical, .movely.medium)
        }
        .refreshable {
            await viewModel.onRefresh()
        }
    }

    // MARK: - Loading Section
    private var loadingSection: some View {
        ScrollView {
            LazyVStack(spacing: .movely.medium) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: .movely.radiusLarge)
                        .fill(.movelyBackgroundElevated)
                        .frame(height: 120)
                        .movelyShimmer(isLoading: true)
                }
            }
            .padding(.horizontal, .movely.screenPaddingHorizontal)
            .padding(.top, .movely.medium)
        }
    }

    // MARK: - Empty State Section
    private var emptyStateSection: some View {
        VStack(spacing: .movely.medium) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundStyle(.movelyPrimary.opacity(0.5))

            Text("No bookings found")
                .font(.movely.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextPrimary)

            Text(selectedTab == .upcoming ? "You don't have any upcoming sessions scheduled." :
                    "You haven't completed any sessions yet.")
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .movely.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error Section
    private func errorSection(message: String, viewModel: BookingsViewModel) -> some View {
        VStack(spacing: .movely.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.movelyError)

            Text(message)
                .font(.movely.subheadline)
                .foregroundStyle(.movelyTextSecondary)
                .multilineTextAlignment(.center)

            MovelyButton("Try Again") {
                Task { await viewModel.onRefresh() }
            }
        }
        .padding(.movely.screenPaddingHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Booking Card
private struct BookingCard: View {
    let booking: Booking

    var body: some View {
        MovelyCard {
            VStack(alignment: .leading, spacing: .movely.small) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(booking.date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .font(.movely.headline)
                            .foregroundStyle(.movelyTextPrimary)

                        Text(booking.date.formatted(.dateTime.hour().minute()))
                            .font(.movely.subheadline)
                            .foregroundStyle(.movelyPrimary)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    StatusBadge(status: booking.status)
                }

                Divider()

                HStack(spacing: .movely.medium) {
                    Label("\(booking.durationInMinutes) min", systemImage: "clock.fill")
                    Label("Session", systemImage: "figure.run")
                }
                .font(.movely.caption1)
                .foregroundStyle(.movelyTextSecondary)

                if let notes = booking.notes {
                    Text("Note: \(notes)")
                        .font(.movely.caption2)
                        .foregroundStyle(.movelyTextSecondary)
                        .padding(.top, .movely.micro)
                        .lineLimit(2)
                }
            }
        }
    }
}

// MARK: - Status Badge
private struct StatusBadge: View {
    let status: BookingStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch status {
        case .pending: return .movelyWarning
        case .confirmed: return .movelyPrimary
        case .completed: return .green
        case .cancelled: return .movelyError
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Bookings - Loaded") {
    BookingsView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}

#Preview("Bookings - Dark") {
    BookingsView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
        .preferredColorScheme(.dark)
}
#endif
