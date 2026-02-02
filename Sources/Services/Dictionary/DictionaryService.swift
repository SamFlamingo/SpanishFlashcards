import Foundation

protocol DictionaryService {
    func lookup(word: String, language: Language) async throws -> DictionaryEntry?
}

struct DictionaryEntry {
    let lemma: String
    let partOfSpeech: String?
    let translations: [String]
    let shortDefinition: String?
}
