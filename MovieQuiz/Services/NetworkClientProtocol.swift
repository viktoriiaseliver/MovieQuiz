import Foundation

protocol NetworkClientProtocol {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
