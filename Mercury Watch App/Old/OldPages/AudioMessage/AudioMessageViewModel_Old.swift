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

class AudioMessageViewModel_Old: NSObject, ObservableObject {
    
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
    
    @Published var state: RecordingState = .recStarted
    @Published var hightlightIndex: Int?
    @Published var isLoadingPlayerWaveform: Bool = false
    
    @Binding var action: ChatAction?
    
    @Published var recorder: RecorderService
    @Published var player: PlayerService?
    
    private var recorderCancellable: AnyCancellable? = nil
    private var playerCancellable: AnyCancellable? = nil
    
    let filePath: URL
    private let chat: ChatCellModel_Old
    private let logger = LoggerService(AudioMessageViewModel_Old.self)
    
    init(chat: ChatCellModel_Old, action: Binding<ChatAction?>) {
        
        // Recording file path
        let recName = "\(UUID().uuidString).m4a"
        let tmpFolder = FileManager.default.tmpFolder
        
        self.filePath = tmpFolder.appendingPathComponent(recName)
        self.recorder = RecorderService(recFilePath: filePath)
        self.chat = chat
        self.state = .recStarted
        self._action = action
        
        super.init()
        
        recorderCancellable = recorder.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        
    }
    
    deinit {
        recorderCancellable?.cancel()
        playerCancellable?.cancel()
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
        action = nil
    }
    
    func didPressMainAction() {
        switch state {
        case .recStarted:
            action = nil
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
    
    func didPressSendButton() -> Bool {
        
        guard state != .sending else { return false }
        
        action = .chatActionUploadingVoiceNote(.init(progress: 0))
        if state == .recStarted {
            recorder.stopRecordingAudio()
        }
        
        state = .sending
        return true
    }
    
    private func createPlayer() {
        DispatchQueue.main.async {
            do {
                self.isLoadingPlayerWaveform = true
                self.player = try PlayerService(audioFilePath: self.filePath, delegate: self)
                self.playerCancellable = self.player!.objectWillChange.sink { [weak self] (_) in
                    self?.objectWillChange.send()
                }
                self.isLoadingPlayerWaveform = false
            } catch {
                self.logger.log(error, level: .error)
            }
            self.state = .recStopped
        }
    }
    
}

extension AudioMessageViewModel_Old: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.player?.stopPlayingAudio()
            self.state = .playPaused
        }
    }
}
