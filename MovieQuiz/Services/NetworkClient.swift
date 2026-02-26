import Foundation

final class NetworkClient: NetworkClientProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    private enum NetworkError: Error {
        case codeError
        case emptyData
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { data, response, error in

            if let error = error {
                handler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse,
               !(200...299).contains(response.statusCode) {
                handler(.failure(NetworkError.codeError))
                return
            }

            guard let data = data else {
                handler(.failure(NetworkError.emptyData))
                return
            }

            handler(.success(data))
        }

        task.resume()
    }
}
