//
//  SpeechManager.swift
//  GUESSITGOOD
//
//  Created by Nicholas Olivieri on 12/28/24.
//



import SwiftUI
import AVFoundation

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var currentPhrase: String?
    private var currentCategory: String?
    private var completion: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    @Published var rate: Float = 0.4 // Default speech rate
    @Published var pitch: Float = 1.3 // Default pitch multiplier

    func reset() {
        currentPhrase = nil
        currentCategory = nil
    }

    // Function to speak text with customization options
    func speak(_ text: String, language: String = "en-US", rate: Float = 0.4, pitch: Float = 1.4, completion: (() -> Void)? = nil) {
        self.completion = completion
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        synthesizer.speak(utterance)
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completion?()
        completion = nil
    }
}

