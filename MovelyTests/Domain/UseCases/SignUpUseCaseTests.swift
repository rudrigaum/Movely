//
//  SignUpUseCaseTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 05/04/26.
//

import Foundation
import Testing
@testable import Movely

// MARK: - SignUp UseCase Tests
@Suite("SignUpUseCase")
@MainActor
struct SignUpUseCaseTests {

    // MARK: - Helpers
    func makeSUT(shouldFail: Bool = false) -> (
        sut: SignUpUseCase,
        repository: AuthRepositoryMock
    ) {
        let repository = AuthRepositoryMock()
        repository.shouldFail = shouldFail
        let sut = SignUpUseCase(repository: repository)
        return (sut, repository)
    }

    // MARK: - Success Tests
    @Suite("Success")
    @MainActor
    struct SuccessTests {

        @Test("Valid inputs should return user with correct role")
        func validInputsReturnsUser() async throws {
            let (sut, _) = SignUpUseCaseTests().makeSUT()

            let user = try await sut.execute(
                name: "Carlos Mendes",
                email: "carlos@movely.com",
                password: "123456",
                role: .trainer
            )

            #expect(user.role == .trainer)
        }

        @Test("Valid student registration should return student role")
        func validStudentRegistration() async throws {
            let (sut, _) = SignUpUseCaseTests().makeSUT()

            let user = try await sut.execute(
                name: "Ana Paula",
                email: "ana@movely.com",
                password: "123456",
                role: .student
            )

            #expect(user.role == .student)
        }
    }

    // MARK: - Validation Tests
    @Suite("Validation")
    @MainActor
    struct ValidationTests {

        @Test("Invalid name should throw invalidName error")
        func invalidNameThrows() async {
            let (sut, _) = SignUpUseCaseTests().makeSUT()

            await #expect(throws: AuthError.self) {
                try await sut.execute(
                    name: "A",
                    email: "user@example.com",
                    password: "123456",
                    role: .student
                )
            }
        }

        @Test("Empty name should throw error")
        func emptyNameThrows() async {
            let (sut, _) = SignUpUseCaseTests().makeSUT()

            await #expect(throws: AuthError.self) {
                try await sut.execute(
                    name: "",
                    email: "user@example.com",
                    password: "123456",
                    role: .student
                )
            }
        }

        @Test("Invalid email should throw invalidEmail error")
        func invalidEmailThrows() async {
            let (sut, _) = SignUpUseCaseTests().makeSUT()

            await #expect(throws: AuthError.invalidEmail) {
                try await sut.execute(
                    name: "Carlos Mendes",
                    email: "notanemail",
                    password: "123456",
                    role: .student
                )
            }
        }

        @Test("Short password should throw weakPassword error")
        func shortPasswordThrows() async {
            let (sut, _) = SignUpUseCaseTests().makeSUT()

            await #expect(throws: AuthError.weakPassword) {
                try await sut.execute(
                    name: "Carlos Mendes",
                    email: "user@example.com",
                    password: "123",
                    role: .student
                )
            }
        }

        @Test("Empty password should throw weakPassword error")
        func emptyPasswordThrows() async {
            let (sut, _) = SignUpUseCaseTests().makeSUT()

            await #expect(throws: AuthError.weakPassword) {
                try await sut.execute(
                    name: "Carlos Mendes",
                    email: "user@example.com",
                    password: "",
                    role: .student
                )
            }
        }
    }

    // MARK: - Failure Tests
    @Suite("Failure")
    @MainActor
    struct FailureTests {

        @Test("Repository failure should propagate error")
        func repositoryFailurePropagates() async {
            let (sut, _) = SignUpUseCaseTests().makeSUT(shouldFail: true)

            await #expect(throws: AuthError.self) {
                try await sut.execute(
                    name: "Carlos Mendes",
                    email: "user@example.com",
                    password: "123456",
                    role: .student
                )
            }
        }
    }
}
