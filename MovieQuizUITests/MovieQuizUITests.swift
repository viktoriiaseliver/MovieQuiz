import XCTest

final class MovieQuizUITests: XCTestCase {

    private func poster(in app: XCUIApplication) -> XCUIElement {
        app.images["Poster"]
    }

    private func indexLabel(in app: XCUIApplication) -> XCUIElement {
        app.staticTexts["Index"]
    }

    func testYesButtonChangesPoster() {
        let app = XCUIApplication()
        app.launch()

        let firstPoster = poster(in: app)
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 10))
        let firstData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()

        let secondPoster = poster(in: app)
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 10))
        let secondData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstData, secondData)
    }

    func testNoButtonChangesPoster() {
        let app = XCUIApplication()
        app.launch()

        let firstPoster = poster(in: app)
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 10))
        let firstData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()

        let secondPoster = poster(in: app)
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 10))
        let secondData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstData, secondData)
    }

    func testAlertAppearsAtEndOfRound() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(indexLabel(in: app).waitForExistence(timeout: 10))

        for _ in 0..<10 {
            app.buttons["Yes"].tap()
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists)
    }

    func testAlertDismissAndCounterReset() {
        let app = XCUIApplication()
        app.launch()

        let index = indexLabel(in: app)
        XCTAssertTrue(index.waitForExistence(timeout: 10))

        for _ in 0..<10 {
            app.buttons["Yes"].tap()
        }

        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))

        alert.buttons["Сыграть ещё раз"].tap()

        XCTAssertFalse(alert.exists)
        XCTAssertEqual(index.label, "1/10")
    }
}
