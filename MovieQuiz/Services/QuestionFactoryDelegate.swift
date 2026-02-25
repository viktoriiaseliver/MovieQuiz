import Foundation

struct QuizQuestion {
    let image: Data
    let text: String
    let correctAnswer: Bool
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error) 
}
