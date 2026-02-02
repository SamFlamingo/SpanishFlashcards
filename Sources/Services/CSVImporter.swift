import Foundation

enum CSVImporterError: Error {
    case fileNotFound, invalidHeader, parseError
}

struct CSVImporter {
    /// Import lexicon entries from bundled CSV for given language.
    static func importCSV(forLanguage language: String) throws -> [LexiconEntry] {
        let fileName = (language == "es") ? "spanish_frequency_5000" : "lexicon_\(language)"
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            print("❌ CSVImporter: File not found for \(fileName).csv")
            throw CSVImporterError.fileNotFound
        }

        print("✅ CSVImporter: Found file at \(fileURL.path)")
        
        let content = try String(contentsOf: fileURL, encoding: .utf8)

        // Determine delimiter: if tabs present but no commas, use tab; else comma.
        let delimiter: Character = (content.contains("\t") && !content.contains(",")) ? "\t" : ","

        var lines = content.components(separatedBy: .newlines)
        lines.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !lines.isEmpty else {
            print("❌ CSVImporter: No lines to parse.")
            throw CSVImporterError.parseError
        }

        let headerLine = lines.removeFirst()
        let expectedHeaders = ["rank", "word", "pos", "definition", "sample", "frequency"]
        let actualHeaders = headerLine.split(separator: delimiter).map {
            $0.trimmingCharacters(in: .whitespaces).lowercased()
        }

        guard actualHeaders.count >= expectedHeaders.count &&
              zip(expectedHeaders, actualHeaders).allSatisfy({ $0 == $1 }) else {
            print("❌ CSVImporter: Invalid header. Found: \(actualHeaders)")
            throw CSVImporterError.invalidHeader
        }

        var entries: [LexiconEntry] = []

        for (index, line) in lines.enumerated() {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }

            var fields: [String] = []
            var currentField = ""
            var inQuotes = false

            for char in line {
                if char == "\"" {
                    inQuotes.toggle()
                } else if char == delimiter && !inQuotes {
                    fields.append(currentField)
                    currentField = ""
                } else {
                    currentField.append(char)
                }
            }
            fields.append(currentField)

            // Repair if too many fields (merge extras into sample)
            if fields.count > expectedHeaders.count {
                let sampleIndex = expectedHeaders.firstIndex(of: "sample")!
                let freqIndex = fields.count - 1
                let sampleJoined = fields[sampleIndex..<freqIndex].joined(separator: String(delimiter))
                var newFields = Array(fields[0..<sampleIndex])
                newFields.append(sampleJoined)
                newFields.append(fields[freqIndex])
                fields = newFields
            }

            if fields.count != expectedHeaders.count {
                print("⚠️ CSVImporter: Skipping malformed line \(index + 2): \(line)")
                continue
            }

            let rank = Int(fields[0]) ?? (index + 1)
            let lemma = fields[1]
            let pos = fields[2]
            let definition = fields[3]
            let sample = fields[4]
            let freqRaw = fields[5]

            let entry = LexiconEntry(rank: rank, lemma: lemma,
                                     partOfSpeech: pos, definition: definition,
                                     sample: sample, frequencyRaw: freqRaw)
            entries.append(entry)
        }

        print("✅ CSVImporter: Parsed \(entries.count) entries for \(language)")
        return entries
    }
}

