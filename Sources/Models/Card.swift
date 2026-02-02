import Foundation

/// Flashcard model including front/back text, attachments, and scheduling fields.
struct Card: Identifiable, Codable {
    let id: UUID
    var front: String
    var back: String
    var definition: String
    var exampleSentence: String
    var partOfSpeech: String? = nil
    var gender: String? = nil
    var notes: String? = nil
    var imageAttachments: [ImageAttachment] = []
    var audioFileName: String? = nil
    // Spaced repetition fields:
    var status: CardStatus = .new
    var easeFactor: Double = 2.5
    var interval: Double = 0.0  // in days
    var due: Date? = nil
    var lapses: Int = 0

    enum CardStatus: String, Codable {
        case new, learning, review, relearning
    }
    enum CodingKeys: String, CodingKey {
        case id, front, back, definition, exampleSentence, partOfSpeech, gender, notes
        case imageAttachments, audioFileName, status, easeFactor, interval, due, lapses
    }

    init(id: UUID = UUID(), front: String, back: String,
         definition: String = "", exampleSentence: String = "",
         partOfSpeech: String? = nil, gender: String? = nil, notes: String? = nil,
         imageAttachments: [ImageAttachment] = [], audioFileName: String? = nil) {
        self.id = id
        self.front = front
        self.back = back
        self.definition = definition
        self.exampleSentence = exampleSentence
        self.partOfSpeech = partOfSpeech
        self.gender = gender
        self.notes = notes
        self.imageAttachments = imageAttachments
        self.audioFileName = audioFileName
        // status, easeFactor, etc. have default values
    }

    // Custom decoder to handle missing fields in older JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        front = try container.decode(String.self, forKey: .front)
        back = try container.decode(String.self, forKey: .back)
        definition = try container.decodeIfPresent(String.self, forKey: .definition) ?? back
        exampleSentence = try container.decodeIfPresent(String.self, forKey: .exampleSentence) ?? ""
        partOfSpeech = try container.decodeIfPresent(String.self, forKey: .partOfSpeech)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        imageAttachments = try container.decodeIfPresent([ImageAttachment].self, forKey: .imageAttachments) ?? []
        audioFileName = try container.decodeIfPresent(String.self, forKey: .audioFileName)
        status = try container.decodeIfPresent(CardStatus.self, forKey: .status) ?? .new
        easeFactor = try container.decodeIfPresent(Double.self, forKey: .easeFactor) ?? 2.5
        interval = try container.decodeIfPresent(Double.self, forKey: .interval) ?? 0.0
        due = try container.decodeIfPresent(Date.self, forKey: .due)
        lapses = try container.decodeIfPresent(Int.self, forKey: .lapses) ?? 0
    }

    // Custom encoder to include fields conditionally
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(front, forKey: .front)
        try container.encode(back, forKey: .back)
        try container.encode(definition, forKey: .definition)
        try container.encode(exampleSentence, forKey: .exampleSentence)
        try container.encodeIfPresent(partOfSpeech, forKey: .partOfSpeech)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(notes, forKey: .notes)
        if !imageAttachments.isEmpty {
            try container.encode(imageAttachments, forKey: .imageAttachments)
        }
        if let audio = audioFileName {
            try container.encode(audio, forKey: .audioFileName)
        }
        // Always encode SRS fields (none are optional in current model)
        try container.encode(status, forKey: .status)
        try container.encode(easeFactor, forKey: .easeFactor)
        try container.encode(interval, forKey: .interval)
        try container.encodeIfPresent(due, forKey: .due)
        try container.encode(lapses, forKey: .lapses)
    }
}
