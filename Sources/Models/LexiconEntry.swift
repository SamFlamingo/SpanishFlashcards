import Foundation

/// A lexicon entry from the imported CSV.
struct LexiconEntry: Identifiable, Codable {
    let rank: Int
    let lemma: String
    let partOfSpeech: String
    let definition: String
    let sample: String
    let frequencyRaw: String
    var id: Int { rank }
}
