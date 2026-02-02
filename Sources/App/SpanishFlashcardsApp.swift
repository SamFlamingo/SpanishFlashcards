import SwiftUI

@main
struct SpanishFlashcardsApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState.lexiconRepository)
                .environmentObject(appState.cardRepository)
                .environmentObject(appState.progressStore)
                .environmentObject(appState.imageStore)
                .environmentObject(appState.networkMonitor)
        }
    }
}
