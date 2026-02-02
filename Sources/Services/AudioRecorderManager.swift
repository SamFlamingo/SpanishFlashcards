import Foundation
import AVFoundation

/// Manages audio recording and playback for flashcards.
class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var micAccessDenied = false
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    public private(set) var currentFileName: String?


    override init() {
        super.init()
        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
        try? session.setActive(true)
    }

    /// Start recording for given card ID.
    func startRecording(for cardID: UUID) {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            beginRecording(cardID: cardID)
        case .denied:
            micAccessDenied = true
        case .undetermined:
            session.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.beginRecording(cardID: cardID)
                    } else {
                        self?.micAccessDenied = true
                    }
                }
            }
        @unknown default:
            return
        }
    }
    
    private func beginRecording(cardID: UUID) {
        let fileName = "\(cardID.uuidString).m4a"
        currentFileName = fileName
        let fm = FileManager.default
        let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dirURL = docsURL.appendingPathComponent("Flashcards/CardAudio", isDirectory: true)
        if !fm.fileExists(atPath: dirURL.path) {
            try? fm.createDirectory(at: dirURL, withIntermediateDirectories: true)
        }
        let fileURL = dirURL.appendingPathComponent(fileName)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("AudioRecorder: Failed to start recording – \(error)")
        }
    }
    
    /// Stop recording.
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    /// Play recorded audio for given file name.
    func startPlayback(fileName: String) {
        let fm = FileManager.default
        let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = docsURL.appendingPathComponent("Flashcards/CardAudio/\(fileName)")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("AudioRecorder: Failed to play – \(error)")
        }
    }
    
    /// Stop playback.
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    // Delegate to update state when done
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
