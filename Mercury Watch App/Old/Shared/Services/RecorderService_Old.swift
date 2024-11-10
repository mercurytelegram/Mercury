//
//  RecordingViewModel.swift
//  Mercury Watch App
//
//  Created by Marco Tammaro on 27/06/24.
//

import Foundation
import SwiftUI
import AVFoundation

class RecorderService_Old: NSObject, ObservableObject {
    
    static let updateInterval: Double = 0.01
    @Published var waveformSamples: [Float] = []
    @Published var elapsedTime: TimeInterval = .zero
    
    private var audioRecorder: AVAudioRecorder?
    private var recFilePath: URL
    private let logger = LoggerService(RecorderService_Old.self)
    var waveformTimer: Timer?
    
    init(recFilePath: URL) {
        
        // Recording file path
        self.recFilePath = recFilePath
        super.init()
        
        waveformTimer = Timer.scheduledTimer(
            withTimeInterval: RecorderService_Old.updateInterval,
            repeats: true,
            block: { [weak self] _ in
                self?.updateWaveform()
            }
        )
        
    }
    
    deinit {
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
            logger.log(error, level: .error)
            return
        }
    }
    
    func startDataTimer() {
        guard let timer = self.waveformTimer else { return }
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        queue.async {
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run()
        }
    }
    
    func updateWaveform() {
        
        guard audioRecorder?.isRecording ?? false
        else { return }
        
        audioRecorder?.updateMeters()
        
        // Gives -160...0 values
        guard let decibel = audioRecorder?.averagePower(forChannel: 0)
        else { return }
        
        // Normalization parameters
        typealias MinMax = (min: Float, max: Float)
        let normalizationFrom: MinMax = (-60, -20)
        let normalizationTo: MinMax = (1.0, 0.1)
        
        // Calculate the normalized value
        let normalizedValue = (decibel - normalizationFrom.min) / (normalizationFrom.max - normalizationFrom.min)
        
        // Scale the normalized value to the end range
        let scaledNormalizedValue = (normalizedValue * (normalizationTo.max - normalizationTo.min)) + normalizationTo.min
        
        self.waveformSamples.append(scaledNormalizedValue)
        self.elapsedTime += RecorderService_Old.updateInterval
        
    }
    
    func startRecordingAudio() {
        logger.log("Start recording")
        audioRecorder?.record()
        startDataTimer()
    }
    
    func stopRecordingAudio() {
        logger.log("Stop recording")
        audioRecorder?.stop()
        waveformTimer?.invalidate()
    }
    
    func clearWaveform() {
        waveformSamples = []
    }
}
