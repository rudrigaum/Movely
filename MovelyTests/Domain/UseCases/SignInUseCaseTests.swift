//
//  SignInUseCaseTests.swift
//  MovelyTests
//
//  Created by Rodrigo Cerqueira Reis on 29/03/26.
//

import Testing
@testable import Movely

// MARK: - SignIn UseCase Tests
@Suite("SignInUseCase")
@MainActor
struct SignInUseCaseTests {

    // MARK: - Helpers
    func makeSUT(shouldFail: Bool = false) -> (
        sut: SignInUseCase,
        repository: AuthRepositoryMock
    ) {
        let repository = AuthRepositoryMock()
        repository.shouldFail = shouldFail
        let sut = SignInUseCase(repository: repository)
        return (sut, repository)
    }

    // MARK: - Success Tests
    @Suite("Success")
    @MainActor
    struct SuccessTests {

        @Test("Valid credentials should return user")
        func validCredentialsReturnsUser() async throws {
            let parent = SignInUseCaseTests()
            let (sut, repository) = parent.makeSUT()
            repository.currentUser = .mockStudent

            let user = try await sut.execute(
                email: "user@example.com",
                password: "123456"
            )

            #expect(user.email == User.mockStudent.email)
            #expect(user.role == .student)
        }

        @Test("Returned user should match repository mock")
        func returnedUserMatchesMock() async throws {
            let parent = SignInUseCaseTests()
            let (sut, _) = parent.makeSUT()

            let user = try await sut.execute(
                email: "trainer@example.com",
                password: "123456"
            )

            #expect(user.id == User.mockStudent.id)
        }
    }

    // MARK: - Validation Tests
    @Suite("Validation")
    @MainActor
    struct ValidationTests {

        @Test("Invalid email should throw invalidEmail error")
        func invalidEmailThrows() async {
            let (sut, _) = SignInUseCaseTests().makeSUT()

            await #expect(throws: AuthError.invalidEmail) {
                try await sut.execute(
                    email: "notanemail",
                    password: "123456"
                )
            }
        }

        @Test("Empty email should throw invalidEmail error")
        func emptyEmailThrows() async {
            let (sut, _) = SignInUseCaseTests().makeSUT()

            await #expect(throws: AuthError.invalidEmail) {
                try await sut.execute(
                    email: "",
                    password: "123456"
                )
            }
        }

        @Test("Empty password should throw weakPassword error")
        func emptyPasswordThrows() async {
            let (sut, _) = SignInUseCaseTests().makeSUT()

            await #expect(throws: AuthError.weakPassword) {
                try await sut.execute(
                    email: "user@example.com",
                    password: ""
                )
            }
        }

        @Test("Short password should throw weakPassword error")
        func shortPasswordThrows() async {
            let (sut, _) = SignInUseCaseTests().makeSUT()

            await #expect(throws: AuthError.weakPassword) {
                try await sut.execute(
                    email: "user@example.com",
                    password: "123"
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
            let (sut, _) = SignInUseCaseTests().makeSUT(shouldFail: true)

            await #expect(throws: AuthError.self) {
                try await sut.execute(
                    email: "user@example.com",
                    password: "123456"
                )
            }
        }
    }
}
