import Foundation

protocol DictionaryService {
    func lookup(word: String, language: Language) async throws -> DictionaryEntry?
}

enum DictionaryLookupError: Error {
    case invalidURL
    case networkFailure
    case decodingFailure
    case notFound
}

struct DictionaryEntry {
    let lemma: String
    let partOfSpeech: String?
    let translations: [String]
    let shortDefinition: String?
}
