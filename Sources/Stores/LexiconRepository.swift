import Foundation

/// Repository responsible for loading and caching the Spanish lexicon.
@MainActor
final class LexiconRepository: ObservableObject {

    /// Loaded lexicon entries (Spanish frequency list).
    @Published private(set) var lexicon: [LexiconEntry] = []

    /// True once the lexicon has been successfully loaded.
    @Published private(set) var isReady: Bool = false

    /// Last load error, if any.
    @Published private(set) var lastError: Error? = nil

    /// Cache location for the lexicon JSON.
    private var cacheURL: URL {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDir
            .appendingPathComponent("LexiconCache", isDirectory: true)
            .appendingPathComponent("lexicon_es_v1.json")
    }

    /// Ensure the lexicon is loaded exactly once.
    /// Loads from cache if available, otherwise imports from bundled CSV and caches it.
    func ensureLoaded(language: String) async {
        guard !isReady else { return }

        isReady = false
        lastError = nil

        let cacheURL = self.cacheURL

        do {
            let entries = try await Task.detached(priority: .userInitiated) {
                let fm = FileManager.default

                // Attempt to load cached lexicon
                if let data = try? Data(contentsOf: cacheURL),
                   let decoded = try? JSONDecoder().decode([LexiconEntry].self, from: data) {
                    return decoded
                }

                // Fallback: import from bundled CSV
                let imported = try CSVImporter.importCSV(forLanguage: language)

                let dir = cacheURL.deletingLastPathComponent()
                if !fm.fileExists(atPath: dir.path) {
                    try fm.createDirectory(at: dir, withIntermediateDirectories: true)
                }

                let jsonData = try JSONEncoder().encode(imported)
                try jsonData.write(to: cacheURL, options: .atomic)

                return imported
            }.value

            self.lexicon = entries
            self.isReady = true
            self.lastError = nil

            print("LexiconRepository: Loaded \(entries.count) entries.")

        } catch {
            self.lexicon = []
            self.isReady = false
            self.lastError = error

            print("LexiconRepository: Failed to load lexicon – \(error)")
        }
    }

    /// Clears cached lexicon and forces a reload.
    func reset(language: String) {
        if FileManager.default.fileExists(atPath: cacheURL.path) {
            try? FileManager.default.removeItem(at: cacheURL)
        }

        lexicon.removeAll()
        isReady = false
        lastError = nil

        Task {
            await ensureLoaded(language: language)
        }
    }

    /// Returns the first `count` lexicon entries.
    func topEntries(count: Int) -> [LexiconEntry] {
        Array(lexicon.prefix(count))
    }

    /// Case-insensitive search across lemma, definition, and part of speech.
    func search(_ query: String) -> [LexiconEntry] {
        let lower = query.lowercased()
        return lexicon.filter { entry in
            entry.lemma.lowercased().contains(lower)
            || entry.definition.lowercased().contains(lower)
            || entry.partOfSpeech.lowercased().contains(lower)
        }
    }
}

