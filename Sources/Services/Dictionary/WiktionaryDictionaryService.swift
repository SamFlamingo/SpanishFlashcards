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
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/es/\(encodedWord)") else {
            throw DictionaryLookupError.invalidURL
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw DictionaryLookupError.networkFailure
        }

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                return nil
            }
            if httpResponse.statusCode >= 400 {
                throw DictionaryLookupError.networkFailure
            }
        }

        let entries: [WiktionaryResponse]
        do {
            entries = try JSONDecoder().decode([WiktionaryResponse].self, from: data)
        } catch {
            throw DictionaryLookupError.decodingFailure
        }
        guard let entry = entries.first else {
            return nil
        }

        let meaning = entry.meanings.first
        return DictionaryEntry(
            lemma: entry.word,
            partOfSpeech: meaning?.partOfSpeech,
            translations: [],
            shortDefinition: meaning?.definitions.first?.definition
        )
    }
}

private struct WiktionaryResponse: Decodable {
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
