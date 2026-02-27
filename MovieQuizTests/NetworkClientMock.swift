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
