import Foundation

struct WiktionaryDictionaryService: DictionaryService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func lookup(word: String, language: Language) async throws -> DictionaryEntry? {
        guard language == .spanish else {
            return nil
        }

        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else {
            return nil
        }

        let encodedWord = trimmedWord.lowercased().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? trimmedWord
        let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/es/\(encodedWord)")!
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            return nil
        }

        let entries = try JSONDecoder().decode([WiktionaryEntry].self, from: data)
        guard let entry = entries.first else {
            return nil
        }

        let meaning = entry.meanings.first
        let definitions = meaning?.definitions.map { $0.definition } ?? []
        return DictionaryEntry(
            lemma: entry.word,
            partOfSpeech: meaning?.partOfSpeech,
            translations: definitions,
            shortDefinition: definitions.first
        )
    }
}

private struct WiktionaryEntry: Decodable {
    let word: String
    let meanings: [WiktionaryMeaning]
}

private struct WiktionaryMeaning: Decodable {
    let partOfSpeech: String?
    let definitions: [WiktionaryDefinition]
}

private struct WiktionaryDefinition: Decodable {
    let definition: String
}
