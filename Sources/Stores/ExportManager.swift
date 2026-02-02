import Foundation

/// Manages exporting app data to a JSON file.
struct ExportManager {
    /// Export card metadata (no binary data) to JSON in the Exports directory.
    /// Returns the file URL if successful.
    static func exportProgress(from cards: [Card]) -> URL? {
        let fm = FileManager.default
        let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let exportsDir = docsURL.appendingPathComponent("Flashcards/Exports", isDirectory: true)
        if !fm.fileExists(atPath: exportsDir.path) {
            try? fm.createDirectory(at: exportsDir, withIntermediateDirectories: true)
        }
        // Build export dictionary
        var exportDict = [String: Any]()
        exportDict["exportDate"] = ISO8601DateFormatter().string(from: Date())
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            exportDict["appVersion"] = version
        }
        // Export cards metadata
        var cardsArray: [[String: Any]] = []
        for card in cards {
            var cardDict: [String: Any] = [
                "id": card.id.uuidString,
                "front": card.front,
                "back": card.back
            ]
            if let audio = card.audioFileName {
                cardDict["audioFileName"] = audio
            }
            if !card.imageAttachments.isEmpty {
                cardDict["imageAttachments"] = card.imageAttachments.map { att in
                    var a = [
                        "fileName": att.fileName
                    ]
                    if let uid = att.unsplashId {
                        a["unsplashId"] = uid
                    }
                    if let name = att.attributionName {
                        a["attributionName"] = name
                    }
                    if let link = att.attributionLink {
                        a["attributionLink"] = link
                    }
                    return a
                }
            }
            // Include SRS fields
            cardDict["status"] = card.status.rawValue
            cardDict["easeFactor"] = card.easeFactor
            cardDict["interval"] = card.interval
            if let dueDate = card.due {
                cardDict["due"] = ISO8601DateFormatter().string(from: dueDate)
            }
            cardDict["lapses"] = card.lapses
            cardsArray.append(cardDict)
        }
        exportDict["cards"] = cardsArray
        // Serialize to JSON
        let jsonURL = exportsDir.appendingPathComponent("export_\(Date().timeIntervalSince1970).json")
        do {
            let data = try JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted)
            try data.write(to: jsonURL, options: .atomic)
            return jsonURL
        } catch {
            print("ExportManager: Failed to export JSON – \(error)")
            return nil
        }
    }
}
