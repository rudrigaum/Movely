//
//  MainTabView.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 09/03/26.
//

import Foundation
import SwiftUI

// MARK: - Tab Item
public enum AppTab: String, CaseIterable {
    case home
    case search
    case bookings
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .bookings: return "Bookings"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .bookings: return "calendar"
        case .profile: return "person"
        }
    }
}

// MARK: - Main Tab View
public struct MainTabView: View {

    // MARK: - Dependencies
    @Environment(AppEnvironment.self) private var env
    @State private var selectedTab: AppTab = .home

    // MARK: - Body
    public var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(.movelyPrimary)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .search:
            SearchView()
        case .bookings:
            BookingsView()
        case .profile:
            ProfileView()
        }
    }
}

// MARK: - Preview
#Preview("MainTabView - Student") {
    MainTabView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
}

#Preview("MainTabView - Dark") {
    MainTabView()
        .environment(AppEnvironment.mock(isAuthenticated: true))
        .preferredColorScheme(.dark)
}
