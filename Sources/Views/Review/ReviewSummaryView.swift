import SwiftUI

/// A summary view displayed when the daily review limit is reached.
struct ReviewSummaryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Daily Review Completed!")
                .font(.title)
                .padding()
            Text("You've reached your daily review limit. Come back tomorrow for more.")
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
