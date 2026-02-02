import SwiftUI

struct ImportView: View {
    @EnvironmentObject var lexiconRepository: LexiconRepository

    var body: some View {
        VStack(spacing: 16) {
            if let _ = lexiconRepository.lastError {
                Text("Failed to import word list. Please try again.")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                Button("Rebuild Lexicon") {
                    lexiconRepository.reset(language: "es")
                }
                .padding(.top, 4)
            } else {
                ProgressView("Importing words...")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
