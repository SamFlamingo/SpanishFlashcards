import Foundation

/// A deterministic spaced repetition scheduler for flashcards.
struct Scheduler {
    enum Rating {
        case again, hard, medium, easy
    }
    private static let minEaseFactor: Double = 1.3
    private static let maxEaseFactor: Double = 3.0
    
    /// Schedule a card based on the user's rating. Returns updated card.
    static func schedule(card: Card, rating: Rating) -> Card {
        var updated = card
        let now = Date()
        let ef = updated.easeFactor
        let interval = updated.interval
        switch rating {
        case .again:
            // Complete failure
            updated.lapses += 1
            updated.easeFactor = max(minEaseFactor, ef - 0.2)
            if updated.status == .new {
                updated.status = .learning
            } else {
                updated.status = .relearning
            }
            // Shorten interval; schedule ~10 min from now
            updated.interval = max(0, interval / 2)
            updated.due = Calendar.current.date(byAdding: .minute, value: 10, to: now)
        case .hard:
            if updated.status == .new {
                updated.status = .learning
            }
            updated.easeFactor = max(minEaseFactor, ef - 0.15)
            // Keep interval; schedule ~10 min
            updated.due = Calendar.current.date(byAdding: .minute, value: 10, to: now)
        case .medium:
            if updated.status == .new {
                updated.status = .learning
            }
            if updated.status == .review {
                updated.interval = interval * updated.easeFactor
            }
            updated.due = Calendar.current.date(byAdding: .minute, value: 30, to: now)
        case .easy:
            updated.status = .review
            updated.easeFactor = min(maxEaseFactor, ef + 0.1)
            if interval < 1 {
                updated.interval = 1
            } else {
                updated.interval = interval * updated.easeFactor
            }
            let days = Int(round(updated.interval))
            updated.due = Calendar.current.date(byAdding: .day, value: days, to: now)
        }
        return updated
    }
    
    /// Ensure a newly created card is scheduled for immediate learning.
    static func ensureNewCardScheduled(_ card: Card) -> Card {
        var updated = card
        if updated.status == .new {
            updated.status = .learning
            updated.due = Date()
            updated.interval = 0
            if updated.easeFactor < 1.3 {
                updated.easeFactor = 2.5
            }
        }
        return updated
    }
}
