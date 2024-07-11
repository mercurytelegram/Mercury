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
    
    @Published var waveformData: [Float] = Array(repeating: 0, count: Waveform.suggestedSamples)
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioRecorder: AVAudioRecorder?
    private var recFilePath: URL
    var waveformTimer: Timer?
    
    init(recFilePath: URL) {
        
        // Recording file path
        self.recFilePath = recFilePath
        super.init()
       
        // Waveform update timer
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        waveformTimer = Timer.scheduledTimer(
            withTimeInterval: RecorderService.updateInterval,
            repeats: true,
            block: updateWaveform
        )
        
        queue.async {
            RunLoop.current.add(self.waveformTimer!, forMode: .default)
            RunLoop.current.run()
        }
        
    }
    
    deinit {
        dispose()
    }
    
    func dispose() {
        waveformTimer?.invalidate()
        audioRecorder?.stop()
        audioRecorder = nil
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
            
            guard let decibel = audioRecorder?.averagePower(forChannel: 0) // Gives -160...0 values
            else { return }
            
            self.waveformData.append(decibel)
            self.waveformData.remove(at: 0)
            self.elapsedTime += RecorderService.updateInterval
        }
        
    }
    
    func startRecordingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Start recording")
        audioRecorder?.record()
    }
    
    func stopRecordingAudio() {
        print("[CLIENT] [\(type(of: self))] [\(#function)] Stop recording")
        audioRecorder?.stop()
    }
    
    func clearWaveform() {
        waveformData = Array(repeating: 0, count: Waveform.suggestedSamples)
    }
}
