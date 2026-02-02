import Foundation
import UIKit

// Unsplash API response models
struct UnsplashPhoto: Identifiable, Codable {
    let id: String
    let alt_description: String?
    let urls: UnsplashPhotoURLs
    let user: UnsplashUser
    let links: UnsplashLinks
}
struct UnsplashPhotoURLs: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}
struct UnsplashUser: Codable {
    let name: String
    let links: UnsplashUserLinks
}
struct UnsplashUserLinks: Codable {
    let html: String
}
struct UnsplashLinks: Codable {
    let download_location: String
}
struct UnsplashSearchResults: Codable {
    let results: [UnsplashPhoto]
}

/// Service for searching and downloading images from Unsplash.
class UnsplashService {
    private static let clientIDKey = "UnsplashAPIKey"
    private static let baseURL = "https://api.unsplash.com"

    /// Search Unsplash for photos matching query.
    static func search(query: String, completion: @escaping ([UnsplashPhoto]?, Error?) -> Void) {
        guard let key = KeychainHelper.load(key: clientIDKey), !key.isEmpty else {
            completion(nil, nil)
            return
        }
        let urlString = "\(baseURL)/search/photos?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&client_id=\(key)"
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let results = try JSONDecoder().decode(UnsplashSearchResults.self, from: data)
                    DispatchQueue.main.async {
                        completion(results.results, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }

    /// Download full image for given Unsplash photo, then perform attribution ping.
    static func download(photo: UnsplashPhoto, completion: @escaping (UIImage?, UnsplashPhoto?) -> Void) {
        guard let key = KeychainHelper.load(key: clientIDKey) else {
            completion(nil, nil)
            return
        }
        // Request image data
        if let rawURL = URL(string: photo.urls.full ?? photo.urls.regular ?? "") {
            URLSession.shared.dataTask(with: rawURL) { data, _, _ in
                var downloadedPhoto: UnsplashPhoto? = nil
                if let data = data, let image = UIImage(data: data) {
                    downloadedPhoto = photo
                    // Attribution ping per Unsplash guidelines
                    if let link = URL(string: "\(photo.links.download_location)?client_id=\(key)") {
                        URLSession.shared.dataTask(with: link).resume()
                    }
                    DispatchQueue.main.async {
                        completion(image, downloadedPhoto)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                }
            }.resume()
        } else {
            completion(nil, nil)
        }
    }
}
