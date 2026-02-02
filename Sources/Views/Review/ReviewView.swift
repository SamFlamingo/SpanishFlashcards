import SwiftUI

struct ReviewView: View {

    @EnvironmentObject var cardRepository: CardRepository
    @EnvironmentObject var progressStore: ProgressStore

    @State private var currentIndex: Int = 0

    // Editing state (kept local; repository remains read-only from the view)
    @State private var pendingEdit: Bool = false
    @State private var draftCard: Card = Card(front: "", back: "")
    @State private var shouldAdvanceOnDismiss: Bool = false

    private var reviewCards: [Card] {
        cardRepository.cards
    }

    var body: some View {
        NavigationStack {
            Group {
                reviewContent
            }
            .navigationTitle("Review")
        }
        .sheet(isPresented: $pendingEdit, onDismiss: {
            guard shouldAdvanceOnDismiss else { return }

            // Persist edits (always) then advance.
            cardRepository.upsert(draftCard)
            progressStore.increment()
            currentIndex += 1

            shouldAdvanceOnDismiss = false
        }) {
            NavigationStack {
                EditCardView(card: $draftCard)
            }
        }
    }

    @ViewBuilder
    private var reviewContent: some View {
        if progressStore.todayReviewedCount >= progressStore.dailyLimit {
            ReviewSummaryView()

        } else if currentIndex < reviewCards.count {
            FlashcardPromptView(
                card: reviewCards[currentIndex],
                onAgain: handleAgain,
                onRate: handleRate
            )

        } else {
            Text("No cards to review right now.")
                .italic()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Handlers

    /// Again always forces edit.
    private func handleAgain(card: Card) {
        startEditing(card: card)
    }

    /// Hard/Good force edit; Easy advances without edit.
    private func handleRate(card: Card, _ rating: Scheduler.Rating) {
        switch rating {
        case .easy:
            // Easy: no edit, just mark reviewed and advance.
            progressStore.increment()
            currentIndex += 1

        default:
            // Anything other than easy: force edit immediately.
            startEditing(card: card)
        }
    }

    private func startEditing(card: Card) {
        draftCard = card
        shouldAdvanceOnDismiss = true
        pendingEdit = true
    }
}

