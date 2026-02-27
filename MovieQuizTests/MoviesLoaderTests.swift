import XCTest
@testable import MovieQuiz

final class MoviesLoaderTests: XCTestCase {
    
    func testLoadMoviesSuccess() {
        let networkClient = NetworkClientMock()
        let sut = MoviesLoader(networkClient: networkClient)
        
        let json = """
        {
          "items": [
            { "id": "1", "rank": "1", "title": "Test", "fullTitle": "Test", "year": "2020",
              "image": "https://example.com", "crew": "Crew", "imDbRating": "9.0", "imDbRatingCount": "1" }
          ],
          "errorMessage": ""
        }
        """.data(using: .utf8)!
        
        networkClient.result = Result<Data, Error>.success(json)
        
        let exp = expectation(description: "loadMovies")
        
        sut.loadMovies { result in
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 1)
            case .failure:
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testLoadMoviesFailure() {
        let networkClient = NetworkClientMock()
        let sut = MoviesLoader(networkClient: networkClient)
        
        let error = NSError(domain: "test", code: 0)
        networkClient.result = Result<Data, Error>.failure(error)
        
        let exp = expectation(description: "loadMovies")
        
        sut.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure:
                XCTAssertTrue(true)
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}
