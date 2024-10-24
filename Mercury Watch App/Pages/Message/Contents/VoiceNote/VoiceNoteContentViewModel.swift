//
//  VoiceNoteContentViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 09/07/24.
//

import Foundation
import TDLibKit
import AVFAudio
import SwiftUI

class VoiceNoteContentViewModel: NSObject, ObservableObject {
    
    let message: MessageVoiceNote
    var player: PlayerService?
    private let logger = LoggerService(AudioMessageViewModel.self)
    
    @Published var loading: Bool = false
    @Published var playing: Bool = false
    @Published var fileUrl: URL?
    
    init(message: MessageVoiceNote) {
        self.message = message
        super.init()
        processAudio()
    }
    
    private func processAudio() {
        loading = true
        Task.detached {
            
            let filePath = await FileService.getFilePath(for: self.message.voiceNote.voice)
            await MainActor.run {
                
                guard let filePath else {
                    self.logger.log("filePath is nil", level: .error)
                    self.loading = false
                    return
                }
                
                do {
                    self.player = try PlayerService(audioFilePath: filePath, delegate: self)
                    self.fileUrl = self.player?.filePath
                    self.loading = false
                    
                } catch {
                    self.logger.log(error, level: .error)
                }
                
            }
        }
    }
    
    func play() {
        
        if self.loading { return }
        
        if playing {
            self.player?.pausePlayingAudio()
            playing = false
        } else {
            self.player?.startPlayingAudio()
            playing = true
        }
    }
    
}

extension VoiceNoteContentViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { playing = false }
    }
}

