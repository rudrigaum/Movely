//
//  ValidatorsTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 25/03/26.
//

import Foundation
import Testing
@testable import Movely

// MARK: - Validators Tests
@Suite("Validators")
struct ValidatorsTests {

    // MARK: - Email Tests
    @Suite("isValidEmail")
    struct EmailTests {

        @Test("Valid emails should return true")
        func validEmails() {
            let validEmails = [
                "user@example.com",
                "user.name@domain.com",
                "user+tag@example.org",
                "user@subdomain.domain.com"
            ]
            for email in validEmails {
                #expect(Validators.isValidEmail(email), "Expected \(email) to be valid")
            }
        }

        @Test("Invalid emails should return false")
        func invalidEmails() {
            let invalidEmails = [
                "",
                "notanemail",
                "@nodomain.com",
                "noatsign.com",
                "spaces in@email.com",
                "user@"
            ]
            for email in invalidEmails {
                #expect(!Validators.isValidEmail(email), "Expected \(email) to be invalid")
            }
        }
    }

    // MARK: - Password Tests
    @Suite("isValidPassword")
    struct PasswordTests {

        @Test("Password with 6 or more characters should return true")
        func validPasswords() {
            let validPasswords = [
                "123456",
                "password",
                "MyStr0ngP@ss!"
            ]
            for password in validPasswords {
                #expect(Validators.isValidPassword(password), "Expected \(password) to be valid")
            }
        }

        @Test("Password with less than 6 characters should return false")
        func invalidPasswords() {
            let invalidPasswords = [
                "",
                "1",
                "12345"
            ]
            for password in invalidPasswords {
                #expect(!Validators.isValidPassword(password), "Expected \(password) to be invalid")
            }
        }
    }

    // MARK: - Name Tests
    @Suite("isValidName")
    struct NameTests {

        @Test("Name with 2 or more characters should return true")
        func validNames() {
            let validNames = [
                "Jo",
                "Carlos",
                "Ana Paula Lima"
            ]
            for name in validNames {
                #expect(Validators.isValidName(name), "Expected \(name) to be valid")
            }
        }

        @Test("Name with less than 2 characters should return false")
        func invalidNames() {
            let invalidNames = [
                "",
                "A"
            ]
            for name in invalidNames {
                #expect(!Validators.isValidName(name), "Expected \(name) to be invalid")
            }
        }
    }
}
