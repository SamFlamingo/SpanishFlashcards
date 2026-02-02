import Foundation
/// Represents a supported language for flashcards.
enum Language: String, Codable {
    case spanish = "es"
    /// A user-friendly display name for the language.
    var displayName: String {
        switch self {
        case .spanish: return "Spanish"
        }
    }
}
