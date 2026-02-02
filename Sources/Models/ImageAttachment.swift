import Foundation

/// Model representing an image attachment for a flashcard, including optional Unsplash metadata.
struct ImageAttachment: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let unsplashId: String?
    let attributionName: String?
    let attributionLink: String?
    
    init(id: UUID = UUID(), fileName: String,
         unsplashId: String? = nil,
         attributionName: String? = nil,
         attributionLink: String? = nil) {
        self.id = id
        self.fileName = fileName
        self.unsplashId = unsplashId
        self.attributionName = attributionName
        self.attributionLink = attributionLink
    }
}
