//
//  MovelyTextField.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 05/03/26.
//

import SwiftUI

// MARK: - TextField State
public enum MovelyTextFieldState {
    case idle
    case focused
    case success
    case error(message: String)
}

// MARK: - MovelyTextField
public struct MovelyTextField: View {

    // MARK: - Properties
    private let title: String
    private let placeholder: String
    private let leadingIcon: String?
    private let trailingIcon: String?
    private let isSecure: Bool
    private let keyboardType: UIKeyboardType

    @Binding private var text: String
    @State private var isFocused: Bool = false
    @State private var isSecureVisible: Bool = false

    private let state: MovelyTextFieldState

    // MARK: - Init
    public init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        state: MovelyTextFieldState = .idle,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.state = state
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: .movely.micro) {
            titleLabel
            inputContainer
            feedbackLabel
        }
    }

    // MARK: - Title Label
    private var titleLabel: some View {
        Text(title)
            .font(.movely.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.movelyTextPrimary)
    }

    // MARK: - Input Container
    private var inputContainer: some View {
        HStack(spacing: .movely.tiny) {
            leadingIconView
            textField
            trailingIconView
        }
        .padding(.horizontal, .movely.small)
        .frame(height: .movely.inputHeight)
        .background(.movelyBackgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: .movely.radiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: .movely.radiusMedium)
                .strokeBorder(borderColor, lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: borderColor)
    }

    // MARK: - Leading Icon
    @ViewBuilder
    private var leadingIconView: some View {
        if let leadingIcon {
            Image(systemName: leadingIcon)
                .font(.system(size: .movely.iconSmall))
                .foregroundStyle(.movelyTextSecondary)
        }
    }

    // MARK: - Text Field
    private var textField: some View {
        Group {
            if isSecure && !isSecureVisible {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .font(.movely.body)
        .foregroundStyle(.movelyTextPrimary)
        .tint(.movelyPrimary)
        .onTapGesture { isFocused = true }
    }

    // MARK: - Trailing Icon
    @ViewBuilder
    private var trailingIconView: some View {
        if isSecure {
            Button {
                isSecureVisible.toggle()
            } label: {
                Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                    .font(.system(size: .movely.iconSmall))
                    .foregroundStyle(.movelyTextSecondary)
            }
        } else if let trailingIcon {
            Image(systemName: trailingIcon)
                .font(.system(size: .movely.iconSmall))
                .foregroundStyle(.movelyTextSecondary)
        }
    }

    // MARK: - Feedback Label
    @ViewBuilder
    private var feedbackLabel: some View {
        if case .error(let message) = state {
            HStack(spacing: .movely.micro) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: .movely.iconSmall))
                Text(message)
                    .font(.movely.caption1)
            }
            .foregroundStyle(.movelyError)
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else if case .success = state {
            HStack(spacing: .movely.micro) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: .movely.iconSmall))
                Text("Looks good!")
                    .font(.movely.caption1)
            }
            .foregroundStyle(.movelySuccess)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Border Color
    private var borderColor: Color {
        switch state {
        case .idle: return isFocused ? .movelyPrimary : .movelyBorder
        case .focused: return .movelyPrimary
        case .success: return .movelySuccess
        case .error: return .movelyError
        }
    }
}

// MARK: - Preview
#Preview("TextField - Light") {
    MovelyTextFieldPreview()
        .preferredColorScheme(.light)
}

#Preview("TextField - Dark") {
    MovelyTextFieldPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Preview View
private struct MovelyTextFieldPreview: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = "Rodrigo"
    @State private var errorText = "invalid@"

    var body: some View {
        ScrollView {
            VStack(spacing: .movely.large) {

                fieldSection(title: "Idle") {
                    MovelyTextField(
                        "Email",
                        placeholder: "you@example.com",
                        text: $email,
                        leadingIcon: "envelope"
                    )
                }

                fieldSection(title: "With Value") {
                    MovelyTextField(
                        "Full Name",
                        placeholder: "Your name",
                        text: $name,
                        state: .success,
                        leadingIcon: "person"
                    )
                }

                fieldSection(title: "Error State") {
                    MovelyTextField(
                        "Email",
                        placeholder: "you@example.com",
                        text: $errorText,
                        state: .error(message: "Please enter a valid email address."),
                        leadingIcon: "envelope"
                    )
                }

                fieldSection(title: "Secure") {
                    MovelyTextField(
                        "Password",
                        placeholder: "Min. 8 characters",
                        text: $password,
                        leadingIcon: "lock",
                        isSecure: true
                    )
                }

                fieldSection(title: "Phone") {
                    MovelyTextField(
                        "Phone Number",
                        placeholder: "+55 (11) 99999-9999",
                        text: $email,
                        leadingIcon: "phone",
                        keyboardType: .phonePad
                    )
                }
            }
            .padding(.movely.small)
        }
        .background(.movelyBackground)
    }

    private func fieldSection(
        title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: .movely.tiny) {
            Text(title.uppercased())
                .font(.movely.caption1)
                .fontWeight(.semibold)
                .foregroundStyle(.movelyTextSecondary)
            Divider()
            content()
        }
    }
}
