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

class AudioMessageViewModel: ObservableObject {
    
    /*
     
     State Diagram:
                                   ┌───────────────┬──────────────────┬──────────────────┬──> sending ──> Final State
                                   │               │                  │                  │
     Initial State ──> recStarted ─┴─> recStopped ─┴─┬─> playStarted ─┴─> playPaused  ───┤
                                                     │                                   │
                                                     └───────────────────────────────────┘
     
     Notice: From each state it is possible to reach the cancel
             state that consist in the sheet dismissal
     
    */
    enum RecordingState {
        case recStarted, recStopped, playStarted, playPaused, sending
    }
    
    @Published var state: RecordingState = .recStarted
    @Published private var recorderVM: RecordingViewModel
    @Published private var playerVM: PlayingViewModel
    
    @Published var waveformData: [Float] = []
    @Published var elapsedTime: TimeInterval = .zero
    
    private var recorderDataCancellable: AnyCancellable?
    private var playerDataCancellable: AnyCancellable?
    
    private let filePath: URL
    private let chat: ChatCellModel
      
    init(chat: ChatCellModel) {
        
        // Recording file path
        let recName = "\(UUID().uuidString).m4a"
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        self.filePath = (urls[0] as URL).appendingPathComponent(recName)
        self.recorderVM = RecordingViewModel(recFilePath: filePath)
        self.playerVM = PlayingViewModel(audioFilePath: filePath)
        self.chat = chat
        self.state = .recStarted
        
        recorderDataCancellable = self.recorderVM.$waveformData.sink { [weak self] _ in
            guard let self, self.state == .recStarted else { return }
            self.manageRecorderData()
        }
        
        playerDataCancellable = self.playerVM.$waveformData.sink(receiveValue: { [weak self] _ in
            guard let self, self.state == .playStarted else { return }
            self.managePlayerData()
        })
        
    }
    
    deinit {
        recorderDataCancellable?.cancel()
        playerDataCancellable?.cancel()
        recorderVM.dispose()
        playerVM.dispose()
    }
    
    private func manageRecorderData() {
        DispatchQueue.main.async {
            withAnimation {
                self.elapsedTime = self.recorderVM.elapsedTime
                self.waveformData = self.recorderVM.waveformData
            }
        }
    }
    
    private func managePlayerData() {
        DispatchQueue.main.async {
            withAnimation {
                self.elapsedTime = self.playerVM.elapsedTime
                self.waveformData = self.playerVM.waveformData
            }
        }
    }
    
    /// Returns true if has recording permission, false otherwise
    func onAppear() async -> Bool {
        let hasPermission = await AVAudioApplication.requestRecordPermission()
        if hasPermission { 
            self.recorderVM.initAudioRecorder()
            self.recorderVM.startRecordingAudio()
        }
        
        return hasPermission
    }
    
    func didPressMainAction() {
        switch state {
        case .recStarted:
            recorderVM.stopRecordingAudio()
            playerVM.initAudioPlayer()
            state = .recStopped
            
        case .recStopped, .playPaused:
            playerVM.startPlayingAudio()
            state = .playStarted
                    
        case .playStarted:
            playerVM.stopPlayingAudio()
            state = .playPaused
            
        default:
            return
        }
    }
    
    func didPressSendButton() async {
        
        if state == .sending { return }
        
        if state == .recStarted {
            recorderVM.stopRecordingAudio()
        }
        
        await MainActor.run {
            state = .sending
        }
        
        let audioFile: InputFile = .inputFileLocal(.init(path: filePath.relativePath))
        let audioDuration = Int(recorderVM.elapsedTime)
        let audioWaveform = (try? Data(contentsOf: filePath)) ?? Data()
        
        let audio: InputMessageVoiceNote = .init(
            caption: nil,
            duration: audioDuration,
            selfDestructType: nil,
            voiceNote: audioFile,
            waveform: audioWaveform
        )
        
        do {
            _ = try await TDLibManager.shared.client?.sendMessage(
                chatId: self.chat.td.id,
                inputMessageContent: .inputMessageVoiceNote(audio),
                messageThreadId: nil,
                options: nil,
                replyMarkup: nil,
                replyTo: nil
            )
            
            // TODO: Delete local file after it has been sent
//             try FileManager.default.removeItem(at: filePath)
            
            print("[CLIENT] [\(type(of: self))] [\(#function)] done")
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] \(error)")
        }
        
    }
}
