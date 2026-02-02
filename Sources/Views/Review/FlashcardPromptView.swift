import SwiftUI

/// A view presenting a single flashcard prompt with reveal and rating controls.
struct FlashcardPromptView: View {
    let card: Card
    var onAgain: (Card) -> Void
    var onRate: (Card, Scheduler.Rating) -> Void

    @State private var isRevealed: Bool = false

    var body: some View {
        VStack {
            Spacer()

            Text(card.front)
                .font(.largeTitle)
                .padding()

            if isRevealed {
                Text(card.definition.isEmpty ? (card.back.isEmpty ? "—" : card.back) : card.definition)
                    .font(.title2)
                    .padding()

                HStack(spacing: 16) {
                    Button("Again") { onAgain(card) }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)

                    Button("Hard") { onRate(card, .hard) }
                        .buttonStyle(.bordered)
                        .tint(.orange)

                    Button("Good") { onRate(card, .medium) }
                        .buttonStyle(.bordered)
                        .tint(.blue)

                    Button("Easy") { onRate(card, .easy) }
                        .buttonStyle(.bordered)
                        .tint(.green)
                }
                .padding()
            }

            Spacer()

            Button(isRevealed ? "Hide" : "Reveal") {
                isRevealed.toggle()
            }
            .padding(.vertical)
        }
    }
}
