import Foundation


final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    init(viewController: MovieQuizViewControllerProtocol,
         statisticService: StatisticServiceProtocol = StatisticService(),
         questionFactory: QuestionFactoryProtocol? = nil) {
        self.viewController = viewController
        self.statisticService = statisticService
        self.questionFactory = questionFactory
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        
        let isCorrect = (isYes == currentQuestion.correctAnswer)
        if isCorrect { correctAnswers += 1 }
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.setButtonsEnabled(false)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "",
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        
        let bestCorrect = bestGame?.correct ?? 0
        let bestTotal = bestGame?.total ?? 0
        let bestDate = bestGame?.date.dateTimeString ?? ""
        let bestGameInfoLine = "Рекорд: \(bestCorrect)\\\(bestTotal) (\(bestDate))"
        
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return [
            currentGameResultLine,
            totalPlaysCountLine,
            bestGameInfoLine,
            averageAccuracyLine
        ].joined(separator: "\n")
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.setButtonsEnabled(true)
        }
    }
}
