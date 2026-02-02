import Foundation

protocol DictionaryService {
    func lookup(word: String, language: Language) async throws -> DictionaryEntry?
}

enum DictionaryLookupError: LocalizedError {
    case invalidURL(String)
    case httpError(status: Int)
    case emptyResponse
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let word):
            return "Invalid URL for lookup word: \(word)"
        case .httpError(let status):
            return "HTTP error: \(status)"
        case .emptyResponse:
            return "Empty response body"
        case .decoding(let error):
            return "Decoding failure: \(error.localizedDescription)"
        case .transport(let error):
            return "Network transport error: \(error.localizedDescription)"
        }
    }
}

struct DictionaryEntry {
    let lemma: String
    let partOfSpeech: String?
    let translations: [String]
    let shortDefinition: String?
}
