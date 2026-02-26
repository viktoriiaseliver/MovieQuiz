import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let userDefaults = UserDefaults.standard
    private var correctAnswersTotal: Int = 0
    private var questionsTotal: Int = 0
    
    var gamesCount: Int = 0
    var bestGame: GameResult?
    
    init() {
        gamesCount = userDefaults.integer(forKey: "gamesCount")
        correctAnswersTotal = userDefaults.integer(forKey: "correctAnswersTotal")
        questionsTotal = userDefaults.integer(forKey: "questionsTotal")
        
        if let date = userDefaults.object(forKey: "bestDate") as? Date {
            let correct = userDefaults.integer(forKey: "bestCorrect")
            let total = userDefaults.integer(forKey: "bestTotal")
            bestGame = GameResult(correct: correct, total: total, date: date)
        }
    }
        
        var totalAccuracy: Double {
            questionsTotal == 0 ? 0 : Double(correctAnswersTotal) / Double(questionsTotal) * 100
        }
        
        func store(correct count: Int, total amount: Int) {
            gamesCount += 1
            correctAnswersTotal += count
            questionsTotal += amount
            
            let currentGame = GameResult(correct: count, total: amount, date: Date())
            
            if let best = bestGame {
                if currentGame.isBetterThan(best) {
                    bestGame = currentGame
                }
            } else {
                bestGame = currentGame
            }
            userDefaults.set(gamesCount, forKey: "gamesCount")
            userDefaults.set(correctAnswersTotal, forKey: "correctAnswersTotal")
            userDefaults.set(questionsTotal, forKey: "questionsTotal")
            
            if let best = bestGame {
                userDefaults.set(best.correct, forKey: "bestCorrect")
                userDefaults.set(best.total, forKey: "bestTotal")
                userDefaults.set(best.date, forKey: "bestDate")
            }
        }
    }
