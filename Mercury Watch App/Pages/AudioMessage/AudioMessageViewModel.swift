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
    
    @Published var waveformData: [Float] = Array(repeating: 0.1, count: Waveform.suggestedSamples)
    @Published var elapsedTime: TimeInterval = .zero
    @Published var hightlightIndex: Int?
    @Published var isLoadingPlayerWaveform: Bool = false
    
    private var recorder: RecorderService
    private var player: PlayerService?
    
    private var recorderDataCancellable: AnyCancellable?
    private var playerDataCancellable: AnyCancellable?
    
    let filePath: URL
    private let chat: ChatCellModel
    private let logger = LoggerService(AudioMessageViewModel.self)
      
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
        
        // Listen for playing time
        playerDataCancellable = self.player?.$elapsedTime.sink { [weak self] value in
            guard let self, self.state == .playStarted else { return }
            self.managePlayerElapsedTime(value)
        }
        
    }
    
    deinit {
        recorderDataCancellable?.cancel()
    }
    
    private func manageRecorderSample(_ sample: Float) {
        DispatchQueue.main.async {
            withAnimation {
                self.elapsedTime = self.recorder.elapsedTime
                self.waveformData.append(sample)
            }
        }
    }
    
    private func managePlayerElapsedTime(_ currentTime: TimeInterval) {
        
        var hightlightIndex = 0
        
        // Check if the current time is within the total time
//        guard currentTime >= 0 && currentTime <= self.recorder.elapsedTime
//        else { return }
        
        let arraySize = self.waveformData.count
        
        // Calculate the index
        let index = Int((currentTime * Double(arraySize)) / self.recorder.elapsedTime)
        
        // Ensure the index does not exceed array size
        if index >= arraySize {
            hightlightIndex = arraySize - 1
        } else {
            hightlightIndex = index
        }
        
        DispatchQueue.main.async {
            withAnimation {
                self.hightlightIndex = hightlightIndex
                self.elapsedTime = currentTime
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
        
        if state == .recStarted {
            recorder.stopRecordingAudio()
        }
        
        state = .sending
        return true
    }
    
    private func createPlayer() {
        
        DispatchQueue.main.async {
            self.isLoadingPlayerWaveform = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                self.player = try PlayerService(audioFilePath: self.filePath, delegate: self)
            } catch {
                self.logger.log(error, level: .error)
            }
            
            let data = Array(self.waveformData.dropFirst(Waveform.suggestedSamples))
            
            guard let min = data.min(), let max = data.max()
            else { return }
            
            let aggregatedData = Waveform.aggregate(data)
            let normalizedData = Waveform.normalize(aggregatedData, from: (min, max))

            DispatchQueue.main.async {
                self.isLoadingPlayerWaveform = false
                self.waveformData = normalizedData
                self.state = .recStopped
            }
            
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
