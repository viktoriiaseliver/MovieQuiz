import Foundation

weak var delegate: QuestionFactoryDelegate?

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
}
