//
//  DictionaryService.swift
//  SpanishFlashcards
//
//  Created by Charlie Saad on 2/1/26.
//

import Foundation

/// Result of a dictionary lookup (stub).
struct DefinitionResult {
    let word: String
    let definition: String
}

/// Service for looking up word definitions.
actor DictionaryService {
    /// Look up the given word (e.g. via web API). Stubbed for now.
    func lookup(word: String) async throws -> DefinitionResult {
        // TODO: Implement actual lookup logic.
        throw URLError(.unsupportedURL)
    }
}
