//
//  MovelyPressButtonStyle.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 08/06/26.
//

import Foundation
import SwiftUI

public struct MovelyPressButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extension
public extension ButtonStyle where Self == MovelyPressButtonStyle {
    static var movelyPress: MovelyPressButtonStyle {
        MovelyPressButtonStyle()
    }
}
