import Foundation

/// Repository responsible for managing flashcards and persisting them locally.
@MainActor
final class CardRepository: ObservableObject {

    /// All cards for the current language (Spanish).
    @Published private(set) var cards: [Card] = []

    /// File location for persisted cards.
    private let storeURL: URL

    init(appPaths: AppPaths) {
        self.storeURL = appPaths.root.appendingPathComponent("cards_es_v1.json")
        load()
    }

    // MARK: - Persistence

    private func load() {
        do {
            let data = try Data(contentsOf: storeURL)
            let decoder = JSONDecoder()
            cards = try decoder.decode([Card].self, from: data)
            print("CardRepository: Loaded \(cards.count) cards.")
        } catch {
            cards = []
            if (error as NSError).code != NSFileReadNoSuchFileError {
                print("CardRepository: Failed to load cards – \(error)")
            }
        }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(cards)

            let dir = storeURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: dir.path) {
                try FileManager.default.createDirectory(
                    at: dir,
                    withIntermediateDirectories: true
                )
            }

            try data.write(to: storeURL, options: .atomic)
        } catch {
            print("CardRepository: Failed to save cards – \(error)")
        }
    }

    // MARK: - Seeding

    /// Seeds blank cards from the lexicon if no cards exist.
    ///
    /// - Important:
    ///   - Called once after lexicon load
    ///   - Never duplicates cards
    ///   - Uses the *current* Card initializer only
    func seedCardsIfNeeded(count: Int, lexiconEntries: [LexiconEntry]) {
        guard cards.isEmpty else { return }
        guard count > 0 else { return }

        let seeded: [Card] = lexiconEntries
            .prefix(count)
            .map { entry in
                Card(
                    front: entry.lemma,
                    back: ""
                )
            }

        cards.append(contentsOf: seeded)
        save()

        print("CardRepository: Seeded \(seeded.count) new cards.")
    }

    // MARK: - CRUD

    func upsert(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        } else {
            cards.append(card)
        }
        save()
    }

    func delete(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards.remove(at: index)
            save()
        }
    }

    // MARK: - Queries

    var count: Int { cards.count }
}

