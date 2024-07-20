//
//  RecordingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 27/06/24.
//

import Foundation
import SwiftUI
import AVFoundation

class RecorderService: NSObject, ObservableObject {
    
    static let updateInterval: Double = 0.10
    
    @Published var waveformSample: Float = 0
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioRecorder: AVAudioRecorder?
    private var recFilePath: URL
    var waveformTimer: Timer?
    
    init(recFilePath: URL) {
        
        // Recording file path
        self.recFilePath = recFilePath
        super.init()
        
        waveformTimer = Timer.scheduledTimer(
            withTimeInterval: RecorderService.updateInterval,
            repeats: true,
            block: updateWaveform
        )
        
    }
    
    deinit {
        dispose()
    }
    
    func dispose() {
        waveformTimer?.invalidate()
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func startDataTimer() {
        guard let timer = self.waveformTimer else { return }
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    func initAudioRecorder() {
        do {
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let recSettings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 48000,
                AVEncoderBitRateKey: 256000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: .max
            ]
            
            audioRecorder = try AVAudioRecorder(url: recFilePath, settings: recSettings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
        } catch {
            print("[CLIENT] [\(type(of: self))] [\(#function)] recorder error: \(error)")
            return
        }
    }
    
    func updateWaveform(_ timer: Timer) {
        
        if audioRecorder?.isRecording ?? false {
            audioRecorder?.updateMeters()
            
            // Gives -160...0 values
            guard let decibel = audioRecorder?.averagePower(forChannel: 0)
            else { return }
            
            // Returns 0...160 values
            let normalizedDecibel = decibel + 160
            
            self.waveformSample = normalizedDecibel
            self.elapsedTime += RecorderService.updateInterval
        }
        
    }
    
    func startRecordingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Start recording")
        audioRecorder?.record()
        startDataTimer()
    }
    
    func stopRecordingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop recording")
        audioRecorder?.stop()
    }
    
    func clearWaveform() {
        waveformSample = 0
    }
}
