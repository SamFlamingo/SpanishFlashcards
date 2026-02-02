import SwiftUI

struct WordListView: View {
    @EnvironmentObject var lexiconRepository: LexiconRepository
    @State private var searchText: String = ""

    var filteredEntries: [LexiconEntry] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return lexiconRepository.lexicon
        } else {
            return lexiconRepository.search(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            if !lexiconRepository.isReady {
                ImportView()
                    .navigationTitle("Words")
            } else {
                List(filteredEntries) { entry in
                    NavigationLink(destination: WordDetailView(entry: entry)) {
                        VStack(alignment: .leading) {
                            Text(entry.lemma)
                                .font(.headline)
                            Text(entry.definition)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .searchable(text: $searchText)
                .navigationTitle("Words")
            }
        }
    }
}
