//
//  RecordingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 21/06/24.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import TDLibKit

@Observable
class VoiceNoteRecordViewModel: NSObject {
    
    /*
     
     State Diagram:
                           ┌───────────────┬───────────────┬─────────────────┬───> sending ──> Final State
                           │               │               │                 │
     Initial State ──> recStarted ───> recStopped ───> playStarted ───> playPaused
                                                           ^                 │
                                                           └─────────────────┘
     
     Notice: From each state it is possible to reach the cancel
     state that consist in the sheet dismissal
     
     */
    
    enum RecordingState {
        case recStarted, recStopped, playStarted, playPaused, sending
    }
    
    var state: RecordingState = .recStarted
    var hightlightIndex: Int?
    var isLoadingPlayerWaveform: Bool = false
    var isPresented: Binding<Bool>
    
    var recorder: RecorderService
    var player: PlayerService?
    
    let sendService: SendMessageService
    let action: Binding<ChatAction?>
    
    var filePath: URL
    private let logger = LoggerService(VoiceNoteRecordViewModel.self)
    
    init(action: Binding<ChatAction?>, sendService: SendMessageService, isPresented: Binding<Bool>) {
        self.sendService = sendService
        
        // Recording file path
        let recName = "\(UUID().uuidString).m4a"
        let tmpFolder = FileManager.default.tmpFolder
        let filePath = tmpFolder.appendingPathComponent(recName)
        
        self.filePath = filePath
        self.recorder = RecorderService(recFilePath: filePath)
        self.state = .recStarted
        self.action = action
        self.isPresented = isPresented
        
        super.init()
    }
    
    /// Returns true if has recording permission, false otherwise
    func onAppear() async -> Bool {
        let hasPermission = await AVAudioApplication.requestRecordPermission()
        if hasPermission {
            self.recorder.initAudioRecorder()
            self.recorder.startRecordingAudio()
        }
        
        return hasPermission
    }
    
    func onDisappear() {
        action.wrappedValue = nil
    }
    
    func didPressMainAction() {
        switch state {
        case .recStarted:
            action.wrappedValue = nil
            recorder.stopRecordingAudio()
            createPlayer()
            
        case .recStopped, .playPaused:
            player?.startPlayingAudio()
            state = .playStarted
            
        case .playStarted:
            player?.stopPlayingAudio()
            state = .playPaused
            
        default:
            return
        }
    }
    
    func didPressSendButton() {
        
        guard state != .sending else { return }
        
        action.wrappedValue = .chatActionUploadingVoiceNote(.init(progress: 0))
        if state == .recStarted {
            recorder.stopRecordingAudio()
        }
        
        state = .sending
        
        sendService.sendVoiceNote(
            filePath,
            Int(recorder.elapsedTime)
        ) {
            self.isPresented.wrappedValue = false
        }
    }
    
    private func createPlayer() {
        DispatchQueue.main.async {
            do {
                self.isLoadingPlayerWaveform = true
                self.player = try PlayerService(audioFilePath: self.filePath, delegate: self)
                self.isLoadingPlayerWaveform = false
            } catch {
                self.logger.log(error, level: .error)
            }
            self.state = .recStopped
        }
    }
    
}

extension VoiceNoteRecordViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.player?.stopPlayingAudio()
            self.state = .playPaused
        }
    }
}

class VoiceNoteRecordViewModelMock: VoiceNoteRecordViewModel {
    init(sendService: SendMessageService, isPresented: Binding<Bool>) {
        super.init(
            action: .constant(nil),
            sendService: sendService,
            isPresented: isPresented
        )
    }
}
