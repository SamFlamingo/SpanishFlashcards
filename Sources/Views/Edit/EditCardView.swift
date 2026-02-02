 
import SwiftUI
import AVFoundation

/// View for creating or editing a flashcard (front/back, images, audio).
struct EditCardView: View {
    @Binding var card: Card
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var audioManager = AudioRecorderManager()
    @State private var showImageSearch = false
    
    var body: some View {
        Form {
            Section(header: Text("Front")) {
                TextField("Front Text", text: $card.front)
            }
            Section(header: Text("Back")) {
                TextField("Back Text", text: $card.back)
            }
            Section(header: Text("Images")) {
                // Display existing images
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(card.imageAttachments) { attachment in
                            if let uiImage = imageStore.loadImage(named: attachment.fileName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                        }
                    }
                }
                // Buttons to add image
                HStack {
                    Button {
                        showImageSearch = true
                    } label: {
                        Label("Add from Unsplash", systemImage: "photo.on.rectangle.angled")
                    }
                    .disabled(!networkMonitor.isConnected || KeychainHelper.load(key: "UnsplashAPIKey") == nil)
                    Spacer()
                }
            }
            Section(header: Text("Audio")) {
                if let existingAudio = card.audioFileName {
                    HStack {
                        if audioManager.isPlaying {
                            Button("Stop Audio") {
                                audioManager.stopPlayback()
                            }
                        } else {
                            Button("Play Audio") {
                                audioManager.startPlayback(fileName: existingAudio)
                            }
                        }
                        Spacer()
                        Button("Delete Audio") {
                            card.audioFileName = nil
                        }
                    }
                    Button(audioManager.isRecording ? "Stop Recording" : "Record Audio") {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                            card.audioFileName = audioManager.currentFileName
                        } else {
                            audioManager.startRecording(for: card.id)
                        }
                    }
                    .padding(.top)
                } else {
                    Button(audioManager.isRecording ? "Stop Recording" : "Record Audio") {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                            card.audioFileName = audioManager.currentFileName
                        } else {
                            audioManager.startRecording(for: card.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Card")
        .sheet(isPresented: $showImageSearch) {
            ImageSearchView { image, photo in
                showImageSearch = false
                if let savedName = imageStore.save(image: image) {
                    let attachment = ImageAttachment(fileName: savedName,
                                                     unsplashId: photo.id,
                                                     attributionName: photo.user.name,
                                                     attributionLink: photo.user.links.html)
                    card.imageAttachments.append(attachment)
                }
            }
        }
    }
}
