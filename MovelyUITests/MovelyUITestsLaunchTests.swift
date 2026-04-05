//
//  MovelyUITestsLaunchTests.swift
//  MovelyUITests
//
//  Created by Rodrigo Cerqueira Reis on 27/02/26.
//

import XCTest

final class MovelyUITestsLaunchTests: XCTestCase {

    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
