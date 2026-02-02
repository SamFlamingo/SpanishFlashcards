import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var lexiconRepository: LexiconRepository
    @EnvironmentObject var cardRepository: CardRepository
    @State private var apiKey: String = KeychainHelper.load(key: "UnsplashAPIKey") ?? ""
    @State private var showKeySaved = false
    @AppStorage("cardSeedCount") private var cardSeedCount = 100

    var body: some View {
        // Optional: If you want to show file path info, you can manually define
        // the CSV location
        let csvPath = Bundle.main.resourceURL?
            .appendingPathComponent("spanish_frequency_5000.csv")
            .path ?? "Not found"

        return NavigationStack {
            Form {
                Section {
                    SecureField("Enter Unsplash Key", text: $apiKey)
                    Button("Save API Key") {
                        KeychainHelper.save(key: "UnsplashAPIKey", value: apiKey)
                        showKeySaved = true
                    }
                    .disabled(apiKey.isEmpty)

                    if KeychainHelper.load(key: "UnsplashAPIKey") != nil {
                        Button("Delete API Key") {
                            KeychainHelper.delete(key: "UnsplashAPIKey")
                            apiKey = ""
                        }
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("Unsplash API Key")
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cache file path:")
                        Text(csvPath)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cards file path:")
                        Text("Stored in Application Support (path not exposed)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Storage Info")
                }

                Section {
                    Button("Export Cards to JSON") {
                        if let exportURL = ExportManager.exportProgress(from: cardRepository.cards) {
                            print("Exported to \(exportURL.path)")
                        }
                    }
                } header: {
                    Text("Export")
                }

                Section {
                    Stepper("Cards to seed: \(cardSeedCount)", value: $cardSeedCount, in: 1...1000)
                } header: {
                    Text("Review Settings")
                }
            }
            .navigationTitle("Settings")
            .alert("API Key Saved", isPresented: $showKeySaved) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your Unsplash API key has been saved securely.")
            }
        }
    }
}

