//
//  CategoryChip.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/06/26.
//

import Foundation
import SwiftUI

public struct CategoryChip: View {
    public let category: TrainingCategory
    public let isSelected: Bool
    public let onTap: () -> Void

    public init(category: TrainingCategory, isSelected: Bool, onTap: @escaping () -> Void) {
        self.category = category
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: .movely.micro) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                Text(category.rawValue)
                    .font(.movely.caption1)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : .movelyTextPrimary)
            .padding(.horizontal, .movely.small)
            .padding(.vertical, .movely.tiny)
            .background(isSelected ? .movelyPrimary : .movelyBackgroundElevated)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? .clear : .movelyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.movelyPress)
    }
}
