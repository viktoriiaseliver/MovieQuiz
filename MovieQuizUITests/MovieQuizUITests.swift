import XCTest

final class MovieQuizUITests: XCTestCase {

    func testYesButtonChangesPoster() {
        let app = XCUIApplication()
        app.launch()

        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testNoButtonChangesPoster() {
        let app = XCUIApplication()
        app.launch()

        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testYesButtonChangesIndexLabel() {
        let app = XCUIApplication()
        app.launch()

        sleep(3)

        app.buttons["Yes"].tap()
        sleep(1)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
}
