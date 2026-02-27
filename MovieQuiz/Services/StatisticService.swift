import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
        
    var totalAccuracy: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
    
    private(set) var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    private(set) var bestGame: GameRecord {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data)
            else {
                return GameRecord(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults: UserDefaults
    
    private var correct: Int {
        get { userDefaults.integer(forKey: Keys.correct.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.correct.rawValue) }
    }
    
    private var total: Int {
        get { userDefaults.integer(forKey: Keys.total.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.total.rawValue) }
    }
        
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
        
    func store(correct count: Int, total amount: Int) {
        correct += count
        total += amount
        gamesCount += 1
        
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
    }
}
