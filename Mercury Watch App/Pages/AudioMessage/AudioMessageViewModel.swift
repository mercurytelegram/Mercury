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

class AudioMessageViewModel: NSObject, ObservableObject {
    
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
    @Published private var recorder: RecorderService
    @Published private var player: PlayerService?
    
    @Published var waveformData: [Float] = Array(repeating: 0, count: Waveform.suggestedSamples)
    @Published var elapsedTime: TimeInterval = .zero
    
    private var recorderDataCancellable: AnyCancellable?
    
    private let filePath: URL
    private let chat: ChatCellModel
      
    init(chat: ChatCellModel) {
        
        // Recording file path
        let recName = "\(UUID().uuidString).m4a"
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        self.filePath = (urls[0] as URL).appendingPathComponent(recName)
        self.recorder = RecorderService(recFilePath: filePath)
        self.chat = chat
        self.state = .recStarted
        
        super.init()
        
        // Listen for recording sample to insert into waveform data
        recorderDataCancellable = self.recorder.$waveformSample.sink { [weak self] newValue in
            guard let self, self.state == .recStarted else { return }
            self.manageRecorderSample(newValue)
        }
        
    }
    
    deinit {
        recorderDataCancellable?.cancel()
        recorder.dispose()
        player?.dispose()
    }
    
    private func manageRecorderSample(_ sample: Float) {
        DispatchQueue.main.async {
            withAnimation {
                self.elapsedTime = self.recorder.elapsedTime
                self.waveformData.append(sample)
            }
        }
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
    
    func didPressMainAction() {
        switch state {
        case .recStarted:
            recorder.stopRecordingAudio()
            
            do {
                self.player = try PlayerService(audioFilePath: filePath, delegate: self)
            } catch {
                print("[CLIENT] [\(type(of: self))] [\(#function)] \(error)")
            }
            
            state = .recStopped
            
            self.waveformData = Array(self.waveformData.dropFirst(Waveform.suggestedSamples))
            
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
    
    func didPressSendButton() async {
        
        if state == .sending { return }
        
        if state == .recStarted {
            recorder.stopRecordingAudio()
        }
        
        await MainActor.run {
            state = .sending
        }
        
        let audioFile: InputFile = .inputFileLocal(.init(path: filePath.relativePath))
        let audioDuration = Int(recorder.elapsedTime)
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

extension AudioMessageViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.player?.stopPlayingAudio()
            self.state = .playPaused
        }
    }
}
