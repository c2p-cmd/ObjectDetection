//
//  SpeechViewModel.swift
//  ObjectDetection
//
//  Created by Sharan Thakur on 20/05/23.
//

import Foundation
import AVFoundation

struct SpeechModel {
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func stopSpeech() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    func textToSpeech(
        textToSpeak text: String = "Hello World",
        interrupt stopSpeaking: Bool = false
    ) {
        if speechSynthesizer.isSpeaking {
            if stopSpeaking {
                speechSynthesizer.stopSpeaking(at: .immediate)
            }
            return
        }
        
        let utterrance = AVSpeechUtterance(string: text)
        utterrance.pitchMultiplier = 1.0
        utterrance.rate = 0.5
        utterrance.voice = AVSpeechSynthesisVoice(language: "en-US")
         
        speechSynthesizer.speak(utterrance)
    }
}
