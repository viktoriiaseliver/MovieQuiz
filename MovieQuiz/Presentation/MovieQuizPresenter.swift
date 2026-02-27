import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Constants
    
    private enum Constants {
        static let questionsAmount = 10
        static let alertTitle = "Этот раунд окончен!"
        static let alertButtonText = "Сыграть ещё раз"
        static let perfectScoreText = "Поздравляем, вы ответили на 10 из 10!"
        static func notPerfectText(correct: Int) -> String {
            "Вы ответили на \(correct) из 10, попробуйте ещё раз!"
        }
    }
        
    private let statisticService: StatisticService = StatisticServiceImplementation()
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
        
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
        
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image, // Data
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(Constants.questionsAmount)"
        )
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: Constants.questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(Constants.questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return [
            currentGameResultLine,
            totalPlaysCountLine,
            bestGameInfoLine,
            averageAccuracyLine
        ].joined(separator: "\n")
    }
    
    // MARK: - Private methods
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = (isYes == currentQuestion.correctAnswer)
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect { correctAnswers += 1 }
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if currentQuestionIndex == Constants.questionsAmount - 1 {
            let text = (correctAnswers == Constants.questionsAmount)
            ? Constants.perfectScoreText
            : Constants.notPerfectText(correct: correctAnswers)
            
            let viewModel = QuizResultsViewModel(
                title: Constants.alertTitle,
                text: text,
                buttonText: Constants.alertButtonText
            )
            
            viewController?.show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
