import XCTest

@testable import MovieQuiz

final class ArrayTests: XCTestCase {

    func testSafeSubscriptReturnsElementWhenIndexInRange() {
        let array = [1, 2, 3]
        XCTAssertEqual(array[safe: 1], 2)
    }

    func testSafeSubscriptReturnsNilWhenIndexOutOfRange() {
        let array = [1, 2, 3]
        XCTAssertNil(array[safe: 10])
    }
}
