import Foundation

/// Manages file system paths for local app storage and ensures required directories exist.
class AppPaths {
    var root: URL
    let lexiconCache: URL
    let cardImages: URL
    let cardAudio: URL
    let exports: URL

    init() {
        let fm = FileManager.default
        do {
            root = try fm.url(for: .applicationSupportDirectory,
                              in: .userDomainMask,
                              appropriateFor: nil, create: true)
                .appendingPathComponent("SpanishFlashcards")
            try fm.createDirectory(at: root, withIntermediateDirectories: true)
        } catch {
            let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            root = docs.appendingPathComponent("SpanishFlashcards")
            try? fm.createDirectory(at: root, withIntermediateDirectories: true)
        }

        // Define subdirectories
        lexiconCache = root.appendingPathComponent("LexiconCache")
        cardImages    = root.appendingPathComponent("CardImages")
        cardAudio     = root.appendingPathComponent("CardAudio")
        exports       = root.appendingPathComponent("Exports")

        // Create all directories
        [lexiconCache, cardImages, cardAudio, exports].forEach { url in
            if !fm.fileExists(atPath: url.path) {
                try? fm.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }

        // Exclude from iCloud backup
        [lexiconCache, cardImages, cardAudio].forEach { originalURL in
            var url = originalURL
            var noBackup = URLResourceValues()
            noBackup.isExcludedFromBackup = true
            try? url.setResourceValues(noBackup)
        }
    }

    func cardsFileURL(for language: Language) -> URL {
        let langCode = language.rawValue
        return root.appendingPathComponent("cards_\(langCode)_v1.json")
    }
}

