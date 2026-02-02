import SwiftUI

struct WordDetailView: View {
    let entry: LexiconEntry
    @EnvironmentObject var cardRepository: CardRepository
    
    var hasFlashcard: Bool {
        cardRepository.cards.contains { card in
            card.front.caseInsensitiveCompare(entry.lemma) == .orderedSame
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.lemma)
                .font(.largeTitle).bold()
            if !entry.partOfSpeech.isEmpty {
                Text(entry.partOfSpeech)
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            Text(entry.definition)
                .font(.title2)
                .padding(.vertical, 4)
            Text(entry.sample)
                .italic()
            Text("Frequency: \(entry.frequencyRaw)")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
            if hasFlashcard {
                Text("✓ Already in your flashcards")
                    .font(.headline)
                    .foregroundColor(.green)
            } else {
                Button("Add to Flashcards") {
                    // Create a new flashcard for this word
                    var newCard = Card(
                        front: entry.lemma,
                        back: entry.definition,
                        definition: entry.definition,
                        exampleSentence: entry.sample
                    )
                    newCard = Scheduler.ensureNewCardScheduled(newCard)
                    cardRepository.upsert(newCard)
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(entry.lemma)
        .navigationBarTitleDisplayMode(.inline)
    }
}
