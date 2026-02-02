import UIKit
import Combine

class ImageStore: ObservableObject {
 
    private let imagesDirectory: URL

    init() {
        let fm = FileManager.default
        let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        imagesDirectory = docsURL.appendingPathComponent("Flashcards/CardImages", isDirectory: true)
        if !fm.fileExists(atPath: imagesDirectory.path) {
            try? fm.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// Save UIImage as PNG to disk; returns a generated file name or nil on failure.
    func save(image: UIImage) -> String? {
        let id = UUID().uuidString
        let fileName = "\(id).png"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        guard let data = image.pngData() else { return nil }
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            print("ImageStore: Error saving image – \(error)")
            return nil
        }
    }
    
    /// Load UIImage from disk given file name.
    func loadImage(named fileName: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return nil }
        return image
    }
    
    /// Delete an image file given its file name.
    func deleteImage(named fileName: String) {
        let fileURL = imagesDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
