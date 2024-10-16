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
    @Published var waveformData: [Float] = []
    
    init(message: MessageVoiceNote) {
        self.message = message
        super.init()
        processAudio()
        processWaveform(message.voiceNote.waveform)
    }
    
    private func processWaveform(_ data: Data) {
        DispatchQueue.global(qos: .userInitiated).async {
            let floatData = [UInt8](data).map({ Float($0) })
            guard let min = floatData.min(), let max = floatData.max()
            else { return }
            
            let aggregatedData = Waveform.aggregate(floatData)
            let normalizedData = Waveform.normalize(aggregatedData, from: (min, max))
            
            DispatchQueue.main.async {
                self.waveformData = normalizedData
            }
        }
    }
    
    private func processAudio() {
        loading = true
        Task.detached {
            
            let filePath = await FileService.getFilePath(for: self.message.voiceNote.voice)
            await MainActor.run {
                
                self.loading = false
                guard let filePath else {
                    self.logger.log("filePath is nil", level: .error)
                    return
                }
                
                do {
                    self.player = try PlayerService(audioFilePath: filePath, delegate: self)
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

