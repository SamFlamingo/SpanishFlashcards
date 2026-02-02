import Foundation

/// Tracks daily review progress (count of cards reviewed per day).
@MainActor
class ProgressStore: ObservableObject {
    @Published var dailyLimit: Int {
        didSet {
            if dailyLimit < 1 {
                dailyLimit = 1
                return
            }
            userDefaults.set(dailyLimit, forKey: dailyLimitKey)
        }
    }
    @Published private(set) var todayReviewedCount: Int = 0
    
    private let userDefaults: UserDefaults
    private let dailyLimitKey = "dailyLimit"
    private let dailyCountKey = "dailyCount"
    private let lastReviewDateKey = "lastReviewDate"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let savedLimit = userDefaults.integer(forKey: dailyLimitKey)
        dailyLimit = savedLimit > 0 ? savedLimit : 20
        // Load date and count
        if let lastDate = userDefaults.object(forKey: lastReviewDateKey) as? Date,
           Calendar.current.isDateInToday(lastDate),
           userDefaults.object(forKey: dailyCountKey) != nil {
            todayReviewedCount = userDefaults.integer(forKey: dailyCountKey)
        } else {
            todayReviewedCount = 0
            userDefaults.set(0, forKey: dailyCountKey)
            userDefaults.set(Date(), forKey: lastReviewDateKey)
        }
    }
    
    /// Call when a review is completed.
    func increment() {
        // Check if we need to roll over
        if let lastDate = userDefaults.object(forKey: lastReviewDateKey) as? Date,
           !Calendar.current.isDateInToday(lastDate) {
            // new day
            todayReviewedCount = 0
            userDefaults.set(0, forKey: dailyCountKey)
            userDefaults.set(Date(), forKey: lastReviewDateKey)
        }
        todayReviewedCount += 1
        userDefaults.set(todayReviewedCount, forKey: dailyCountKey)
    }
    
    /// Reset counts (used in full reset).
    func resetAllCounts() {
        todayReviewedCount = 0
        userDefaults.set(0, forKey: dailyCountKey)
        userDefaults.set(Date(), forKey: lastReviewDateKey)
    }
}
