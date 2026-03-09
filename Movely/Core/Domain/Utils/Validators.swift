//
//  Validators.swift
//  Movely
//
//  Created by Rodrigo Cerqueira Reis on 06/03/26.
//

import Foundation

// MARK: - Validators
public enum Validators {

    // MARK: - Email
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    // MARK: - Password
    public static func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }

    // MARK: - Name
    public static func isValidName(_ name: String) -> Bool {
        name.count >= 2
    }
}
