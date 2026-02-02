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
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.dictionaryapi.dev"
        components.path = "/api/v2/entries/es/\(encodedWord)"
        guard let url = components.url else {
            throw DictionaryLookupError.invalidURL(trimmedWord)
        }
        debugLog("Dictionary lookup URL: \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            debugLog("Dictionary lookup transport error: \(error.localizedDescription)")
            throw DictionaryLookupError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DictionaryLookupError.httpError(status: -1)
        }
        debugLog("Dictionary lookup HTTP status: \(httpResponse.statusCode)")
        debugLogResponseBodySnippet(data: data)

        if httpResponse.statusCode == 404 {
            return nil
        }
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            throw DictionaryLookupError.httpError(status: httpResponse.statusCode)
        }
        if data.isEmpty {
            throw DictionaryLookupError.emptyResponse
        }

        let entries: [DictionaryAPIRoot]
        do {
            entries = try JSONDecoder().decode([DictionaryAPIRoot].self, from: data)
        } catch {
            debugLog("Dictionary lookup decoding error: \(error.localizedDescription)")
            throw DictionaryLookupError.decoding(error)
        }
        guard let entry = entries.first else {
            return nil
        }

        let meaning = entry.meanings?.first
        let partOfSpeech = meaning?.partOfSpeech
        let definition = meaning?.definitions?.first?.definition
        guard partOfSpeech != nil || definition != nil else {
            return nil
        }

        return DictionaryEntry(
            lemma: entry.word ?? trimmedWord,
            partOfSpeech: partOfSpeech,
            translations: [],
            shortDefinition: definition
        )
    }
}

private struct DictionaryAPIRoot: Decodable {
    let word: String?
    let meanings: [DictionaryMeaning]?
}

private struct DictionaryMeaning: Decodable {
    let partOfSpeech: String?
    let definitions: [DictionaryDefinition]?
}

private struct DictionaryDefinition: Decodable {
    let definition: String?
}

private func debugLog(_ message: String) {
    #if DEBUG
    print("[DictionaryLookup] \(message)")
    #endif
}

private func debugLogResponseBodySnippet(data: Data) {
    #if DEBUG
    guard !data.isEmpty else {
        print("[DictionaryLookup] Response body: <empty>")
        return
    }
    if let bodyString = String(data: data, encoding: .utf8) {
        let snippet = bodyString.prefix(200)
        print("[DictionaryLookup] Response body (first 200 chars): \(snippet)")
    } else {
        print("[DictionaryLookup] Response body: <non-utf8>")
    }
    #endif
}
