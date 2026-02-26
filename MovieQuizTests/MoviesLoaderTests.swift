import XCTest
@testable import MovieQuiz

final class NetworkClientMock: NetworkClientProtocol {
    var result: Result<Data, Error>?

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if let result {
            handler(result)
        }
    }
}

final class MoviesLoaderTests: XCTestCase {

    func testLoadMoviesSuccess() {
        let expectation = expectation(description: "loadMovies completion")

        let client = NetworkClientMock()
        
        let json = #"{"items":[]}"#
        client.result = .success(Data(json.utf8))

        let sut = MoviesLoader(networkClient: client)

        sut.loadMovies { result in
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 0)
            case .failure:
                XCTFail("Expected success, got failure")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadMoviesFailure() {
        let expectation = expectation(description: "loadMovies completion")

        let client = NetworkClientMock()
        client.result = .failure(NSError(domain: "test", code: 0))

        let sut = MoviesLoader(networkClient: client)

        sut.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure:
                XCTAssertTrue(true)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
