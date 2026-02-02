import SwiftUI

/// View for searching Unsplash images and selecting one.
struct ImageSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var results: [UnsplashPhoto] = []
    @State private var searchTerm: String = ""
    @State private var isSearching: Bool = false

    var onImageSelect: (UIImage, UnsplashPhoto) -> Void

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search Unsplash", text: $searchTerm, onCommit: performSearch)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: performSearch) {
                    Text("Search")
                }
                .disabled(searchTerm.isEmpty || !networkMonitor.isConnected || KeychainHelper.load(key: "UnsplashAPIKey") == nil)

                if !networkMonitor.isConnected {
                    Text("Offline: Cannot search.")
                        .foregroundColor(.red)
                }

                if KeychainHelper.load(key: "UnsplashAPIKey") == nil {
                    Text("Enter Unsplash API key in Settings to search.")
                        .font(.caption).italic()
                }

                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                }

                List(results) { photo in
                    Button {
                        selectPhoto(photo)
                    } label: {
                        HStack {
                            if let thumbString = photo.urls.thumb,
                               let thumbURL = URL(string: thumbString),
                               let data = try? Data(contentsOf: thumbURL),
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(4)
                            }

                            VStack(alignment: .leading) {
                                Text(photo.alt_description ?? "No description")
                                    .font(.subheadline)
                                Text("by \(photo.user.name)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Images")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func performSearch() {
        guard !searchTerm.isEmpty, networkMonitor.isConnected else { return }
        isSearching = true
        UnsplashService.search(query: searchTerm) { photos, error in
            isSearching = false
            if let photos = photos {
                results = photos
            }
        }
    }

    private func selectPhoto(_ photo: UnsplashPhoto) {
        UnsplashService.download(photo: photo) { image, downloaded in
            if let img = image, let photoData = downloaded {
                onImageSelect(img, photoData)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

