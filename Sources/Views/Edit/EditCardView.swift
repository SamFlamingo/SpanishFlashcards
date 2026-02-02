 
import SwiftUI
import AVFoundation

/// View for creating or editing a flashcard (front/back, images, audio).
struct EditCardView: View {
    @Binding var card: Card
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var audioManager = AudioRecorderManager()
    @State private var showImageSearch = false
    @State private var showDrawingCanvas = false

    private let partOfSpeechOptions = [
        "Noun",
        "Verb",
        "Adjective",
        "Adverb",
        "Pronoun",
        "Preposition",
        "Conjunction",
        "Interjection",
        "Article / Determiner",
        "Phrase / Expression",
        "Other"
    ]

    private let genderOptions = [
        "Masculine",
        "Feminine",
        "Masculine & Feminine",
        "Neutral",
        "Invariable",
        "Not applicable"
    ]

    private var definitionBinding: Binding<String> {
        Binding(
            get: { card.definition },
            set: { newValue in
                card.definition = newValue
                card.back = newValue
            }
        )
    }

    private var notesBinding: Binding<String> {
        Binding(
            get: { card.notes ?? "" },
            set: { newValue in
                card.notes = newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : newValue
            }
        )
    }

    private var isSaveDisabled: Bool {
        card.front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || card.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || card.exampleSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section(header: Text("Front")) {
                TextField("Front Text", text: $card.front)
            }

            Section(header: Text("Definition")) {
                multilineField(text: definitionBinding, placeholder: "Definition")
            }

            Section(header: Text("Example Sentence")) {
                multilineField(text: $card.exampleSentence, placeholder: "Example Sentence")
            }

            Section(header: Text("Part of Speech")) {
                Picker("Part of Speech", selection: $card.partOfSpeech) {
                    Text("None").tag(String?.none)
                    ForEach(partOfSpeechOptions, id: \.self) { option in
                        Text(option).tag(Optional(option))
                    }
                }
            }

            if card.partOfSpeech == "Noun" {
                Section(header: Text("Gender")) {
                    Picker("Gender", selection: $card.gender) {
                        Text("None").tag(String?.none)
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(Optional(option))
                        }
                    }
                }
            }

            Section(header: Text("Notes")) {
                multilineField(text: notesBinding, placeholder: "Notes")
            }

            Section(header: Text("Images")) {
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
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        showImageSearch = true
                    } label: {
                        HStack {
                            Label("Add from Unsplash", systemImage: "photo.on.rectangle.angled")
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .disabled(!networkMonitor.isConnected || KeychainHelper.load(key: "UnsplashAPIKey") == nil)

                    Button {
                        showDrawingCanvas = true
                    } label: {
                        HStack {
                            Label("Add Drawing", systemImage: "pencil.and.outline")
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        .interactiveDismissDisabled(isSaveDisabled)
        .onChange(of: card.partOfSpeech) { newValue in
            if newValue != "Noun" {
                card.gender = nil
            }
        }
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
        .fullScreenCover(isPresented: $showDrawingCanvas) {
            NavigationStack {
                DrawingCanvasView(
                    onSave: { image in
                        if let savedName = imageStore.save(image: image) {
                            let attachment = ImageAttachment(fileName: savedName)
                            card.imageAttachments.append(attachment)
                        }
                    },
                    onCancel: {
                        showDrawingCanvas = false
                    }
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dismiss()
                }
                .disabled(isSaveDisabled)
            }
        }
    }

    private func multilineField(text: Binding<String>, placeholder: String) -> some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
            TextEditor(text: text)
                .frame(minHeight: 90)
        }
    }
}
