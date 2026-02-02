import SwiftUI

struct StatsView: View {
    @EnvironmentObject var cardRepository: CardRepository
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        Form {
            Section(header: Text("Review Progress")) {
                HStack {
                    Text("Daily review limit")
                    Spacer()
                    Text("\(progressStore.dailyLimit)")
                }
                HStack {
                    Text("Reviewed today")
                    Spacer()
                    Text("\(progressStore.todayReviewedCount)")
                }
            }

            Section(header: Text("Flashcards")) {
                HStack {
                    Text("Total cards")
                    Spacer()
                    Text("\(cardRepository.cards.count)")
                }
            }

            Section(header: Text("Actions")) {
                Button("Reset Review Count") {
                    progressStore.resetAllCounts()
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Stats")
    }
}

