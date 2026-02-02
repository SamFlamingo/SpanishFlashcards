import SwiftUI

/// Application-wide state and shared services.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Repositories & Services (single source of truth)

    @Published var cardRepository: CardRepository
    @Published var progressStore: ProgressStore

    @Published var lexiconRepository = LexiconRepository()
    @Published var imageStore = ImageStore()
    @Published var networkMonitor = NetworkMonitor()

    // MARK: - Settings

    /// Number of cards to seed on first launch only.
    @AppStorage("cardSeedCount") private var cardSeedCount: Int = 100

    // MARK: - Init

    init() {
        let paths = AppPaths()

        self.cardRepository = CardRepository(appPaths: paths)
        self.progressStore = ProgressStore()

        // Load lexicon, then seed cards if needed
        Task { [weak self] in
            guard let self else { return }

            await lexiconRepository.ensureLoaded(language: "es")

            guard lexiconRepository.isReady else {
                assertionFailure("Lexicon failed to load; cannot seed cards.")
                return
            }

            // Seed only if repository is empty (idempotent by design)
            cardRepository.seedCardsIfNeeded(
                count: cardSeedCount,
                lexiconEntries: lexiconRepository.lexicon
            )
        }
    }
}

