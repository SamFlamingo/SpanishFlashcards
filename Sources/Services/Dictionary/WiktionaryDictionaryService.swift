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
        #if DEBUG
        print("📘 Dictionary lookup called for:", word)
        print("📘 Dictionary URL:", url.absoluteString)
        #endif
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw DictionaryLookupError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DictionaryLookupError.http(-1)
        }
        #if DEBUG
        print("📘 Status:", httpResponse.statusCode)
        print("📘 Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
        #endif

        if httpResponse.statusCode == 404 {
            return nil
        }
        if httpResponse.statusCode != 200 {
            throw DictionaryLookupError.http(httpResponse.statusCode)
        }
        if data.isEmpty {
            return nil
        }

        let entries: [DictionaryAPIRoot]
        do {
            entries = try JSONDecoder().decode([DictionaryAPIRoot].self, from: data)
        } catch {
            throw DictionaryLookupError.decoding(error)
        }
        guard let entry = entries.first else {
            return nil
        }

        let meaning = entry.meanings.first
        let partOfSpeech = meaning?.partOfSpeech
        let definition = meaning?.definitions.first?.definition
        guard partOfSpeech != nil || definition != nil else {
            return nil
        }

        return DictionaryEntry(
            lemma: entry.word,
            partOfSpeech: partOfSpeech,
            translations: [],
            shortDefinition: definition
        )
    }
}

private struct DictionaryAPIRoot: Decodable {
    let word: String
    let meanings: [DictionaryMeaning]
}

private struct DictionaryMeaning: Decodable {
    let partOfSpeech: String?
    let definitions: [DictionaryDefinition]
}

private struct DictionaryDefinition: Decodable {
    let definition: String
}
