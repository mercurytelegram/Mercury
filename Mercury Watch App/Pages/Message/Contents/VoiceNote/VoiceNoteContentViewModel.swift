//
//  VoiceNoteContentViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/07/24.
//

import Foundation
import TDLibKit
import AVFAudio

class VoiceNoteContentViewModel: NSObject, ObservableObject {
    
    let message: MessageVoiceNote
    private let logger = LoggerService(AudioMessageViewModel.self)
    
    @Published var loading: Bool = false
    @Published var playing: Bool = false
    
    init(message: MessageVoiceNote) {
        self.message = message
    }
    
    func play() {
        
        loading = true
        Task {
            
            let filePath = await FileService.getFilePath(for: message.voiceNote.voice)
            await MainActor.run {
                
                loading = false
                guard let filePath else {
                    logger.log("filePath is nil", level: .error)
                    return
                }
                
                do {
                    let audioPlayer = try PlayerService(audioFilePath: filePath, delegate: self)
                    audioPlayer.startPlayingAudio()
                    playing = true
                } catch {
                    logger.log(error, level: .error)
                }
                
            }
        }
    }
    
}

extension VoiceNoteContentViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { playing = false }
    }
}

