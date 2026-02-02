import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ReviewView()
                .tabItem {
                    Label("Review", systemImage: "rectangle.stack.fill")
                }
            WordListView()
                .tabItem {
                    Label("Words", systemImage: "book.closed.fill")
                }
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
