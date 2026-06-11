//
//  FlowLayout.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 10/06/26.
//

import Foundation
import SwiftUI

// MARK: - Flow Layout
public struct FlowLayout: Layout {
    public let spacing: CGFloat

    public init(spacing: CGFloat = .movely.small) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
            .reduce(0) { $0 + $1 + spacing }
        return CGSize(width: proposal.width ?? 0, height: max(0, height - spacing))
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var offsetY = bounds.minY
        for row in rows {
            var offsetX = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: offsetX, y: offsetY), proposal: .unspecified)
                offsetX += size.width + spacing
            }
            offsetY += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var offsetX: CGFloat = 0
        let maxWidth = proposal.width ?? 0

        for subview in subviews {
            let width = subview.sizeThatFits(.unspecified).width
            if offsetX + width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                offsetX = 0
            }
            rows[rows.count - 1].append(subview)
            offsetX += width + spacing
        }
        return rows
    }
}
