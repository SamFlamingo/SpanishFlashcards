import Foundation

protocol DictionaryService {
    func lookup(word: String, language: Language) async throws -> DictionaryEntry?
}

enum DictionaryLookupError: Error {
    case http(Int)
    case decoding(Error)
    case network(Error)
}

struct DictionaryEntry {
    let lemma: String
    let partOfSpeech: String?
    let translations: [String]
    let shortDefinition: String?
}
